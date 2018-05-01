begin;

  \set epsg_code 2154

  -- Schemas

  create schema if not exists abc_montbel;

  comment on schema abc_montbel is 'Données concernant l''atlas de la biodiversité communale autour du lac de Montbel';

  -- Tables

  create table abc_montbel.grid (
    id smallint primary key,
    geometry geometry(Polygon, 4326) not null
  );

  comment on table abc_montbel.grid is 'Maillage du périmètre de l''étude';

  create table abc_montbel.observation (
    id uuid default uuid_generate_v4() primary key,
    study varchar(15) references common.study on delete cascade on update cascade,
    protocol varchar(15) references common.protocol on delete cascade on update cascade,
    observation_date date not null,
    taxon int not null references ref.taxon on delete cascade on update cascade,
    quoted_name text not null default '',
    observation_method int references ref.observation_method on delete cascade on update cascade,
    count_range int4range not null default '[1, 1]',
    count_method varchar(3) not null references ref.count_method on delete cascade on update cascade,
    picture_id text not null default '',
    is_confident boolean,
    comments text not null default '',
    geometry geometry(Point, 4326) not null,
    -- metadata
    dc_title varchar(250) not null constraint title_cannot_be_empty check (dc_title != ''),
    dc_date_created timestamp not null,
    dc_date_modified timestamp not null,
    dc_date_submitted date,
    dc_date_accepted date,
    dc_date_issued date,
    dc_creator text not null constraint creator_cannot_be_empty check (dc_creator != ''),
    validator text constraint validator_cannot_be_empty check (validator != ''),
    dc_publisher text not null default '',
    dc_language text not null references ref.language_code,
    dc_type text not null constraint type_cannot_be_empty check (dc_type != '')
  );

  comment on table abc_montbel.observation is 'Observations réalisées lors des inventaires';

  create table abc_montbel.observer (
    observation uuid not null references abc_montbel.observation on delete cascade on update cascade,
    name text not null constraint observer_name_cannot_be_empty check (name != ''),
    primary key (observation, name)
  );

  comment on table abc_montbel.observer is 'Relie une observation à ses observateurs';

  -- Views

  create or replace view abc_montbel.observation_updatable_view as (
    with obs_observer(id, names) as (
      select obs.id, array_agg(observer.name)
        from abc_montbel.observation as obs
        left join abc_montbel.observer as observer on observer.observation = obs.id
        group by obs.id
    )
    select obs.id,
        st.short_title as study,
        prot.short_title as protocol,
        obs.observation_date,
        array_to_json(obs_observer.names) as observers,  -- this is why we need an updatable view
        obs.taxon,
        sciname.value as taxon_name,
        obs.quoted_name,
        obs.observation_method,
        obsmeth.name as observation_method_name,
        obs.count_range,
        lower(obs.count_range) as count_min, -- this is also why we need an updatable view
        upper(obs.count_range) - 1 as count_max, -- this is also why we need an updatable view
        obs.count_method,
        cntmeth.name as count_method_name,
        case obs.picture_id
          when '' then false
          else true
        end as has_picture,
        obs.picture_id,
        obs.is_confident,
        obs.comments,
        st_asgeojson(obs.geometry) as geometry,
        grid.id as grid_cell,
        obs.dc_title,
        obs.dc_date_created,
        obs.dc_date_modified,
        obs.dc_date_submitted,
        obs.dc_date_accepted,
        obs.dc_date_issued,
        obs.dc_creator,
        obs.validator,
        obs.dc_publisher,
        obs.dc_language,
        obs.dc_type
      from abc_montbel.observation as obs
      left join obs_observer on obs_observer.id = obs.id
      left join common.study as st on st.code = obs.study
      left join common.protocol as prot on prot.code = obs.protocol
      left join ref.scientific_name as sciname on sciname.taxon = obs.taxon and sciname.is_preferred = true
      left join ref.observation_method as obsmeth on obsmeth.code = obs.observation_method
      left join ref.count_method as cntmeth on cntmeth.code = obs.count_method
      left join abc_montbel.grid as grid on st_contains(grid.geometry, obs.geometry)
  );

  comment on view abc_montbel.observation_updatable_view is 'View to be modified to edit main `observation` table';

  create or replace view wfs.abc_montbel as
  with obs_observer as (
    select obs.id as id, string_agg(observer.name, ', ') as names
      from abc_montbel.observation as obs
      left join abc_montbel.observer as observer on observer.observation = obs.id
      group by obs.id
  )
  select obs.id as id,
      obs.observation_date as date_obs,
      obs_observer.names as observateurs,
      obs.taxon as id_taxref,
      sciname.value as nom_sci,
      meth.name as methode_obs,
      case obs.picture_id
        when '' then false
        else true
      end as photo_existante,
      obs.is_confident as est_certain,
      obs.comments as remarques,
      st_astext(st_transform(obs.geometry, :epsg_code)) as geometry
    from abc_montbel.observation as obs
    left join obs_observer on obs_observer.id = obs.id
    left join ref.taxon as taxon on taxon.taxref_id = obs.taxon
    left join ref.scientific_name as sciname on sciname.taxon = taxon.taxref_id and sciname.is_preferred = true
    left join ref.observation_method as meth on meth.code = obs.observation_method
    order by date_obs asc;

  comment on view wfs.abc_montbel is 'To be served via WFS';

  -- Triggers

  create or replace function tg_add_missing_data ()
    returns trigger
    language plpgsql
  as $$
  declare
  begin
    if NEW.id is null then  -- Generate UUID
      NEW.id := uuid_generate_v4();
    end if;
    if NEW.count_range is null then
      NEW.count_range := format('[%s, %s]', NEW.count_min, NEW.count_max)::int4range;
    end if;
    NEW.geometry := st_setsrid(st_geomfromgeojson(NEW.geometry), 4326);
    if NEW.quoted_name is null then
      NEW.quoted_name := '';
    end if;
    if NEW.dc_date_created is null then
      NEW.dc_date_created := now();
    end if;
    if NEW.dc_date_modified is null then
      NEW.dc_date_modified := now();
    end if;
    if NEW.dc_publisher is null then
      NEW.dc_publisher := '';
    end if;
    if NEW.dc_type is null then
      NEW.dc_type := 'event';
    end if;
    -- Populate observers
    with obs(id) as (
      insert into abc_montbel.observation
      select * from json_populate_record(null::abc_montbel.observation, row_to_json(NEW))
      returning id
    )
    insert into abc_montbel.observer
    select obs.id, observer.name
    FROM obs, (select json_array_elements_text(NEW.observers) AS name) as observer;
    -- TODO: Populate subject : | obs_id | taxon_name |
    return null;
  end;
  $$;

  create or replace function tg_update_date_modified ()
    returns trigger
    language plpgsql
  as $$
  declare
  begin
    if NEW.dc_date_modified = OLD.dc_date_modified then
      NEW.dc_date_modified = now();
    end if;
    return NEW;
  end;
  $$;

  drop trigger if exists add_missing_data on abc_montbel.observation_updatable_view;
  drop trigger if exists update_date_modified on abc_montbel.observation;

  create trigger add_missing_data
  instead of insert
  on abc_montbel.observation_updatable_view
  for each row
    execute procedure tg_add_missing_data();

  create trigger update_date_modified
  before update
  on abc_montbel.observation
  for each row
    execute procedure tg_update_date_modified();

  -- Data

  copy abc_montbel.grid (id, geometry) from stdin;
1	SRID=4326;POLYGON ((1.94632435952215 42.9933411374992,1.94508452448257 42.9945361025115,1.94711252669479 42.9978282133819,1.947796200955 42.9983577295328,1.94788699324558 42.9933564337342,1.94632435952215 42.9933411374992))
2	SRID=4326;POLYGON ((1.947796200955 42.9983577295328,1.95117500713629 43.0009744641939,1.9587668861646 43.0024565248182,1.95876688638885 43.0024565248204,1.95998460636285 43.0019882806415,1.96013735388542 42.9934755626702,1.94788699324558 42.9933564337342,1.947796200955 42.9983577295328))
3	SRID=4326;POLYGON ((1.95998460636285 43.0019882806415,1.9643357651886 43.0003149769438,1.96580841758131 42.9968498039424,1.96836218745044 42.9935547622202,1.96013735388542 42.9934755626702,1.95998460636285 43.0019882806415))
4	SRID=4326;POLYGON ((1.92356838121526 42.9841216104664,1.92355090797389 42.9842575314989,1.92355090797301 42.9842575315462,1.92614323469937 42.9845868673916,1.9291518258782 42.9864673131014,1.93181860089985 42.987013112109,1.93368592651953 42.9884177079896,1.93570742741922 42.9893832413744,1.93580179360326 42.9842433601539,1.92356838121526 42.9841216104664))
5	SRID=4326;POLYGON ((1.93570742741922 42.9893832413744,1.93687401588609 42.9899404097223,1.93858453410672 42.9903609278422,1.93761736660727 42.9917383857379,1.93817784834023 42.9926870527893,1.94082508386134 42.9931588580323,1.94424750468843 42.9923698795898,1.94631930870891 42.9912348090117,1.94738182542983 42.9923218923697,1.94632435952215 42.9933411374992,1.94788699324558 42.9933564337342,1.94805020370555 42.9843638645688,1.93580179360326 42.9842433601539,1.93570742741922 42.9893832413744))
6	SRID=4326;POLYGON ((1.94788699324558 42.9933564337342,1.96013735388542 42.9934755626702,1.96029866443349 42.9844829740995,1.94805020370555 42.9843638645688,1.94788699324558 42.9933564337342))
7	SRID=4326;POLYGON ((1.96836218745044 42.9935547622202,1.96858067831667 42.9932728311669,1.9724185594538 42.9918563206568,1.97254717519794 42.984600688737,1.96029866443349 42.9844829740995,1.96013735388542 42.9934755626702,1.96836218745044 42.9935547622202))
8	SRID=4326;POLYGON ((1.9724185594538 42.9918563206568,1.97448752959458 42.9910926066844,1.97644792109784 42.9855195418909,1.97676560413882 42.9846409070197,1.97254717519794 42.984600688737,1.9724185594538 42.9918563206568))
9	SRID=4326;POLYGON ((1.92612595253341 42.975153051733,1.92637516933612 42.9753928187206,1.9269153915384 42.9766822370081,1.93008983264958 42.976363809028,1.92928538640502 42.9771117535957,1.92728050375875 42.977833220268,1.92685196982104 42.9796514370808,1.92739420041731 42.9804523909468,1.92641392264149 42.9814714546729,1.92388060666677 42.9816927626312,1.92356838121526 42.9841216104664,1.93580179360326 42.9842433601539,1.93596685273683 42.9752508804063,1.92612595253341 42.975153051733))
10	SRID=4326;POLYGON ((1.93580179360326 42.9842433601539,1.94805020370555 42.9843638645688,1.94821336353989 42.9753713651921,1.93596685273683 42.9752508804063,1.93580179360326 42.9842433601539))
11	SRID=4326;POLYGON ((1.94805020370555 42.9843638645688,1.96029866443349 42.9844829740995,1.96045992494504 42.9754904553208,1.94821336353989 42.9753713651921,1.94805020370555 42.9843638645688))
12	SRID=4326;POLYGON ((1.96029866443349 42.9844829740995,1.97254717519794 42.984600688737,1.97270653636342 42.9756081507835,1.96045992494504 42.9754904553208,1.96029866443349 42.9844829740995))
13	SRID=4326;POLYGON ((1.97676560413882 42.9846409070197,1.97771403010578 42.9820176288829,1.97942855591976 42.9795650304443,1.98055985317466 42.9776046289631,1.9818765834866 42.9762716216466,1.98200357343863 42.9756965679248,1.97270653636342 42.9756081507835,1.97254717519794 42.984600688737,1.97676560413882 42.9846409070197))
14	SRID=4326;POLYGON ((1.93606380527919 42.9699676036686,1.93312177863289 42.970021518866,1.92874890311868 42.9716348392211,1.92569284849363 42.9721842290317,1.92553554698735 42.9745850231946,1.92612595253341 42.975153051733,1.93596685273683 42.9752508804063,1.93606380527919 42.9699676036686))
15	SRID=4326;POLYGON ((1.94836562083366 42.9669773020815,1.94557047659812 42.9678248121385,1.94136351072343 42.969647363543,1.93752272604402 42.9699408377844,1.93606380527919 42.9699676036686,1.93596685273683 42.9752508804063,1.94821336353989 42.9753713651921,1.94836562083366 42.9669773020815))
16	SRID=4326;POLYGON ((1.95027761454857 42.9663975145545,1.94836562083366 42.9669773020815,1.94821336353989 42.9753713651921,1.96045992494504 42.9754904553208,1.96062113544334 42.9664980065417,1.95027761454857 42.9663975145545))
17	SRID=4326;POLYGON ((1.96045992494504 42.9754904553208,1.97270653636342 42.9756081507835,1.97286584810452 42.9666156828328,1.96062113544334 42.9664980065417,1.96045992494504 42.9754904553208))
18	SRID=4326;POLYGON ((1.98200357343863 42.9756965679248,1.9822596476443 42.974536942495,1.98234015029207 42.9734276970897,1.98289571652403 42.9726002437718,1.98436522664865 42.97208301828,1.98502951858637 42.9713648006592,1.98511061016709 42.9667319646762,1.97286584810452 42.9666156828328,1.97270653636342 42.9756081507835,1.98200357343863 42.9756965679248))
26	SRID=4326;POLYGON ((1.98502951858637 42.9713648006592,1.98561666568589 42.9707299724599,1.98564124797443 42.9700914868964,1.98611595948852 42.9696729414178,1.98618171324055 42.969033363095,1.98513906047347 42.9677632550128,1.98551519815239 42.9669121930432,1.98584167764047 42.9667388630987,1.98511061016709 42.9667319646762,1.98502951858637 42.9713648006592))
19	SRID=4326;POLYGON ((1.9606327170081 42.9658518730289,1.96038212107806 42.9658980700376,1.95729783171141 42.9649155511865,1.95033432554982 42.9663803169803,1.95027761454857 42.9663975145545,1.96062113544334 42.9664980065417,1.9606327170081 42.9658518730289))
20	SRID=4326;POLYGON ((1.97293826298223 42.9625272730323,1.96507870734909 42.9650321519029,1.9606327170081 42.9658518730289,1.96062113544334 42.9664980065417,1.97286584810452 42.9666156828328,1.97293826298223 42.9625272730323))
21	SRID=4326;POLYGON ((1.98474727692131 42.9579763461605,1.98015943649816 42.9604959910213,1.97661421519302 42.9610228864637,1.97384243490946 42.9622390586315,1.97293826298223 42.9625272730323,1.97286584810452 42.9666156828328,1.98511061016709 42.9667319646762,1.98526764227472 42.9577585249779,1.98474727692131 42.9579763461605))
22	SRID=4326;POLYGON ((1.98584167764047 42.9667388630987,1.98725496639461 42.9659885164257,1.98786446079644 42.9656811855014,1.98885249674824 42.9649276027155,1.99025727145316 42.9640655749695,1.99142896541781 42.9636536112919,1.99172660305075 42.9631485840923,1.99245670514476 42.9626357878716,1.99293760107631 42.9627376817564,1.99385119604322 42.9623230906904,1.9953501328518 42.9618751533448,1.99744801955131 42.9614911114703,1.99751088697628 42.9578544166674,1.98531198458339 42.9577399634172,1.98526764227472 42.9577585249779,1.98511061016709 42.9667319646762,1.98584167764047 42.9667388630987))
23	SRID=4326;POLYGON ((1.99744801955131 42.9614911114703,1.99795099433019 42.9613990294308,2.0004275149781 42.9611194624024,2.00020056234199 42.9599322409856,2.0001246872184 42.958174396725,1.99990809389206 42.9578767450943,1.99751088697628 42.9578544166674,1.99744801955131 42.9614911114703))
24	SRID=4326;POLYGON ((1.99755411465068 42.9553535654563,1.99628612222373 42.9546441821469,1.99367622181213 42.9550730987938,1.99323320229641 42.9555716126725,1.98952873356873 42.9561210539226,1.98788559861326 42.9566626049362,1.98531198458339 42.9577399634172,1.99751088697628 42.9578544166674,1.99755411465068 42.9553535654563))
25	SRID=4326;POLYGON ((1.99990809389206 42.9578767450943,1.99842775316903 42.9558423073908,1.99755411465068 42.9553535654563,1.99751088697628 42.9578544166674,1.99990809389206 42.9578767450943))
\.

  -- Studies, protocols and forms

  insert into common.study
  (code, title, short_title, dates, description, pictogram, is_public, allow_no_protocol, is_active, perimeter)
  values
  (
    'ABCMON18',
    'Atlas de la biodiversité communale autour du lac de Montbel - 2018-2019',
    'ABC Montbel',
    '[2018-01-01, 2019-12-31]',
    'Inventaire participatif pour contribuer à l''atlas de la biodiversité communale (ABC) autour du lac de Montbel',
    'https://ariegenature.fr/wp-content/uploads/2018/04/logo-cc-mirepoix.jpg',
    true,
    true,
    true,
    'SRID=4326;MultiPolygon (((1.98474727692131037 42.95797634616046423, 1.98015943649816029 42.96049599102131111, 1.97661421519302305 42.96102288646367384, 1.97384243490946076 42.9622390586315035, 1.96507870734909251 42.96503215190288216, 1.96038212107805521 42.96589807003763184, 1.95729783171141491 42.9649155511864933, 1.95033432554981889 42.96638031698033444, 1.94557047659811544 42.96782481213845983, 1.94136351072343305 42.96964736354304648, 1.93752272604402442 42.96994083778436391, 1.93312177863289225 42.97002151886596266, 1.92874890311868241 42.97163483922108185, 1.92569284849363398 42.97218422903170421, 1.92553554698734586 42.97458502319455675, 1.92637516933612329 42.97539281872063555, 1.92691539153839608 42.97668223700807033, 1.93008983264957923 42.9763638090279585, 1.92928538640501701 42.97711175359565061, 1.92728050375874593 42.97783322026797492, 1.92685196982104046 42.97965143708083957, 1.92739420041730924 42.98045239094683723, 1.92641392264148781 42.98147145467294195, 1.92388060666676841 42.98169276263119087, 1.92355090796789718 42.98425753154555906, 1.92614323469937032 42.98458686739164136, 1.92915182587819567 42.9864673131013646, 1.93181860089984636 42.98701311210903242, 1.93368592651953497 42.9884177079895764, 1.93687401588609376 42.98994040972232966, 1.93858453410672138 42.99036092784221097, 1.93761736660726758 42.99173838573794626, 1.93817784834023144 42.99268705278931435, 1.94082508386133967 42.99315885803233073, 1.94424750468842622 42.9923698795897522, 1.94631930870891035 42.99123480901165806, 1.94738182542983207 42.99232189236969504, 1.94508452448257341 42.99453610251151758, 1.94711252669478729 42.99782821338194339, 1.95117500713629366 43.00097446419393066, 1.95876688631709395 43.00245652484795755, 1.9643357651886022 43.00031497694383376, 1.9658084175813082 42.99684980394242473, 1.96858067831666639 42.99327283116690523, 1.97448752959457785 42.99109260668441834, 1.97644792109784029 42.98551954189090196, 1.97771403010577851 42.98201762888292876, 1.97942855591976041 42.97956503044427734, 1.98055985317466265 42.97760462896305711, 1.98187658348660478 42.97627162164659609, 1.98225964764429818 42.97453694249504963, 1.982340150292069 42.97342769708970422, 1.98289571652403263 42.97260024377175824, 1.98436522664864934 42.97208301828001709, 1.98561666568588735 42.97072997245992099, 1.98564124797443231 42.97009148689635083, 1.98611595948851516 42.96967294141784777, 1.98618171324055171 42.96903336309500787, 1.98513906047346844 42.96776325501279814, 1.9855151981523913 42.96691219304315723, 1.98725496639461241 42.9659885164257247, 1.9878644607964393 42.96568118550136717, 1.98885249674823794 42.96492760271546274, 1.99025727145315789 42.96406557496948864, 1.99142896541781411 42.96365361129190319, 1.991726603050755 42.96314858409226645, 1.99245670514475814 42.96263578787162629, 1.99293760107630535 42.96273768175640839, 1.9938511960432217 42.96232309069041833, 1.99535013285179708 42.96187515334482043, 1.99795099433018697 42.96139902943078681, 2.00042751497810123 42.96111946240237245, 2.00020056234199384 42.9599322409856228, 2.00012468721840442 42.95817439672499916, 1.99842775316902976 42.95584230739075338, 1.9962861222237327 42.95464418214686475, 1.993676221812128 42.95507309879381097, 1.99323320229641476 42.95557161267247892, 1.98952873356872884 42.95612105392260816, 1.98788559861326442 42.95666260493619149, 1.98474727692131037 42.95797634616046423)))'
  );

  insert into common.protocol
  (code, title, short_title, version, description, is_public, is_active, pictogram)
  values
  (
    'ABCMONPROTPUB1',
    'Protocole pour l''inventaire participatif sur l''atlas de la biodiversité communale autour du lac de Montbel - v1',
    'Protocole fiche terrain', '1.0.0', 'Protocole à respecter lors des inventaires participatifs autour du lac de Montbel avec les fiches de terrain',
    true,
    true,
    'https://ariegenature.fr/wp-content/uploads/2018/04/logo-cc-mirepoix.jpg'
  );

  insert into common.form
  (code, title, short_title, version, description, component_name, json_description, allow_no_protocol, is_active, pictogram)
  values
  (
    'ABCMONFORM1',
    'Formulaire « fiche terrain » ABC Montbel - v1',
    'Fiche terrain',
    '1.0.0',
    'Formulaire correspondant à la fiche terrain lors des inventaires participatifs autour du lac de Montbel',
    '',
    '{
      "slug": "abc-montbel",
      "model": {
        "study": "ABCMON18",
        "protocol": "ABCMONPROTPUB1",
        "observation_date": null,
        "observers": [],
        "taxon": null,
        "quoted_name": "",
        "count_min": 1,
        "count_max": null,
        "count_method": null,
        "observation_method": null,
        "picture_id": "",
        "is_confident": true,
        "comments": "",
        "dc_language": "fra",
        "dc_creator": null,
        "dc_title": null
      },
      "tabs": [
        {
          "id": 0,
          "title": "Date",
          "schema": {
            "fields": [
              {
                "id": "date",
                "size": "is-small",
                "type": "b-datepicker",
                "model": "observation_date",
                "inline": true,
                "required": true,
                "validator": "date",
                "fieldLabel": "Date"
              }
            ]
          }
        },
        {
          "id": 1,
          "title": "Identification",
          "schema": {
            "fields": [
              {
                "id": "taxon",
                "api": "/backend/taxon",
                "icon": "flower",
                "size": "is-small",
                "type": "b-autocomplete",
                "model": "taxon",
                "required": true,
                "validator": "integer",
                "fieldLabel": "Espèce",
                "placeholder": "Commencer à saisir le nom du taxon...",
                "searchParam": "q",
                "selectField": "taxon_id",
                "displayField": "name",
                "resultProperty": "results"
              },
              {
                "id": "count-min",
                "icon": "code-greater-than-or-equal",
                "size": "is-small",
                "type": "b-input",
                "inputType": "number",
                "model": "count_min",
                "required": true,
                "fieldLabel": "Effectif minimal (ou exact)",
                "validator": "integer"
              },
              {
                "id": "count-max",
                "icon": "code-less-than-or-equal",
                "size": "is-small",
                "type": "b-input",
                "inputType": "number",
                "model": "count_max",
                "fieldLabel": "Effectif maximal",
                "fieldHelp": "Laisser vide si effectif minimal est exact",
                "fieldType": "is-primary",
                "validator": "integer"
              },
              {
                "id": "count-method",
                "type": "b-radio-button",
                "size": "is-small",
                "model": "count_method",
                "fieldLabel": "Méthode de dénombrement",
                "values": [
                  {"id": "Co", "text": "<span class=\"icon\"><i class=\"mdi mdi-counter\"><\/i><\/span><span>Compté<\/span>"},
                  {"id": "Ca", "text": "<span class=\"icon\"><i class=\"mdi mdi-sigma\"><\/i><\/span><span>Calculé<\/span>"},
                  {"id": "Es", "text": "<span class=\"icon\"><i class=\"mdi mdi-tilde\"><\/i><\/span><span>Estimé<\/span>"}
                ],
                "required": true,
                "validator": "string"
              }
            ]
          }
        },
        {
          "id": 2,
          "title": "Détails",
          "schema": {
            "fields": [
              {
                "id": "observation-method",
                "icon": "glasses",
                "size": "is-small",
                "type": "b-select",
                "model": "observation_method",
                "values": [
                  {"id": 0, "title": "Vu"},
                  {"id": 1, "title": "Entendu"},
                  {"id": 2, "title": "Coquilles d''œuf"},
                  {"id": 4, "title": "Empreintes"},
                  {"id": 5, "title": "Exuvie"},
                  {"id": 6, "title": "Fèces/Guano/Epreintes"},
                  {"id": 7, "title": "Mues"},
                  {"id": 8, "title": "Nid/Gîte"},
                  {"id": 9, "title": "Pelote de réjection"},
                  {"id": 10, "title": "Restes dans pelote de réjection"},
                  {"id": 11, "title": "Poils/plumes/phanères"},
                  {"id": 12, "title": "Restes de repas"},
                  {"id": 13, "title": "Spore"},
                  {"id": 14, "title": "Pollen"},
                  {"id": 17, "title": "Fleur"},
                  {"id": 18, "title": "Feuille"},
                  {"id": 20, "title": "Autre"},
                  {"id": 21, "title": "Inconnu"},
                  {"id": 23, "title": "Galerie/terrier"},
                  {"id": 25, "title": "Vu et entendu"}
                ],
                "required": true,
                "validator": ["integer", "required"],
                "fieldLabel": "Type de contact",
                "placeholder": "Sélectionner une méthode"
              },
              {
                "id": "picture-id",
                "type": "b-input",
                "inputType": "text",
                "fieldLabel": "Nom de fichier de la photo",
                "placeholder": "180415-PL-desman-001.jpg",
                "fieldHelp": "Laisser vide s''il n''y a pas de photo",
                "icon": "file-image",
                "size": "is-small",
                "model": "picture_id",
                "validator": "string"
              },
              {
                "id": "confidence",
                "size": "is-small",
                "type": "b-switch",
                "model": "is_confident",
                "textOn": "Identification certaine",
                "textOff": "Identification incertaine",
                "fieldLabel": "Certitude"
              }
            ]
          }
        },
        {
          "id": 3,
          "title": "Métadonnées",
          "schema": {
            "fields": [
              {
                "id": "observers",
                "min": 1,
                "icon": "human-greeting",
                "size": "is-small",
                "type": "b-taginput",
                "model": "observers",
                "tagType": "is-primary",
                "required": true,
                "fieldHelp": "Séparer par des virgules",
                "fieldLabel": "Observateur(s)",
                "validators": ["array", "required"],
                "placeholder": "Ajouter un observateur"
              },
              {
                "id": "comments",
                "size": "is-small",
                "type": "b-input",
                "model": "comments",
                "inputType": "textarea",
                "fieldLabel": "Vous pouvez ajouter des remarques à cette observation"
              }
            ]
          }
        }
      ]
    }',
    false,
    true,
    'https://ariegenature.fr/wp-content/uploads/2018/04/logo-cc-mirepoix.jpg'
  );

  insert into common.study_protocol
  (study, protocol)
  values
  ('ABCMON18', 'ABCMONPROTPUB1');

  insert into common.protocol_form
  (protocol, form)
  values
  ('ABCMONPROTPUB1', 'ABCMONFORM1');

commit;
