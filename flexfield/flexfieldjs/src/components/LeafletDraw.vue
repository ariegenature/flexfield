<template>
  <div>
    <slot></slot>
  </div>
</template>

<script>
import L from 'leaflet'
import 'leaflet-draw'
import 'leaflet-draw/dist/leaflet.draw.css'

const mapEvents = [
  L.Draw.Event.CREATED,
  L.Draw.Event.EDITED,
  L.Draw.Event.DELETED,
  L.Draw.Event.DRAWSTART,
  L.Draw.Event.DRAWSTOP,
  L.Draw.Event.DRAWVERTEX,
  L.Draw.Event.EDITSTART,
  L.Draw.Event.EDITMOVE,
  L.Draw.Event.EDITRESIZE,
  L.Draw.Event.EDITVERTEX,
  L.Draw.Event.EDITSTOP,
  L.Draw.Event.DELETESTART,
  L.Draw.Event.DELETESTOP
]

const toolbarEvents = [
  L.Draw.Event.TOOLBAROPENED,
  L.Draw.Event.TOOLBARCLOSED
]

const props = {
  position: {
    type: String,
    default: 'topleft'
  },
  polyline: {
    type: Boolean,
    default: true
  },
  polygon: {
    type: Boolean,
    default: true
  },
  rectangle: {
    type: Boolean,
    default: true
  },
  circle: {
    type: Boolean,
    default: true
  },
  marker: {
    type: Boolean,
    default: true
  },
  circleMarker: {
    type: Boolean,
    default: false
  },
  removeTitle: {
    type: String,
    default: 'Supprimer des données'
  },
  editTitle: {
    type: String,
    default: 'Modifier des données'
  },
  polylineTitle: {
    type: String,
    default: 'Ajouter une ligne'
  },
  polygonTitle: {
    type: String,
    default: 'Ajouter un polygone'
  },
  rectangleTitle: {
    type: String,
    default: 'Ajouter un rectangle'
  },
  circleTitle: {
    type: String,
    default: 'Ajouter un disque'
  },
  markerTitle: {
    type: String,
    default: 'Ajouter un point'
  },
  circleMarkerTitle: {
    type: String,
    default: 'Ajouter un point (rond)'
  },
  polylineTooltipStart: {
    type: String,
    default: 'Cliquer pour commencer la ligne'
  },
  polylineTooltipCont: {
    type: String,
    default: 'Cliquer pour ajouter un sommet à la ligne'
  },
  polylineTooltipEnd: {
    type: String,
    default: 'Cliquer sur le dernier sommet pour terminer la ligne'
  },
  polygonTooltipStart: {
    type: String,
    default: 'Cliquer pour commencer le polygone'
  },
  polygonTooltipCont: {
    type: String,
    default: 'Cliquer pour ajouter un sommet au polygone'
  },
  polygonTooltipEnd: {
    type: String,
    default: 'Cliquer sur le premier sommet pour terminer le polygone'
  },
  rectangleTooltip: {
    type: String,
    default: 'Cliquer à une extrémité et laisser appuyer pour commencer le rectangle'
  },
  circleTooltip: {
    type: String,
    default: 'Cliquer au centre et laisser appuyer pour commencer le disque'
  },
  markerTooltip: {
    type: String,
    default: 'Cliquer pour ajouter le point'
  },
  circleMarkerTooltip: {
    type: String,
    default: 'Cliquer pour ajouter le point'
  },
  polylineOptions: {
    type: Object,
    default: () => ({})
  },
  polygonOptions: {
    type: Object,
    default: () => ({})
  },
  rectangleOptions: {
    type: Object,
    default: () => ({})
  },
  circleOptions: {
    type: Object,
    default: () => ({})
  },
  markerOptions: {
    type: Object,
    default: () => ({})
  },
  circleMarkerOptions: {
    type: Object,
    default: () => ({})
  },
  edit: {
    type: Boolean,
    default: false
  },
  remove: {
    type: Boolean,
    default: false
  },
  removeAll: {
    type: Boolean,
    default: false
  },
  editableLayer: {
    type: Object,
    default: () => ({})
  }
}

export default {
  name: 'LeafletDraw',
  props: props,
  mounted () {
    var drawOptions = {}
    Object.assign(drawOptions, {
      polyline: this.polyline ? this.polylineOptions : false,
      polygon: this.polygon ? this.polygonOptions : false,
      rectangle: this.rectangle ? this.rectangleOptions : false,
      circle: this.circle ? this.circleOptions : false,
      marker: this.marker ? this.markerOptions : false,
      circlemarker: this.circleMarker ? this.circleMarkerOptions : false
    })
    var editOptions = false
    if (this.edit) {
      editOptions = {}
      Object.assign(editOptions, {
        featureGroup: this.editableLayer
      })
      if (!this.remove) {
        Object.assign(editOptions, {
          remove: false
        })
      }
    }
    var options = {
      position: this.position,
      draw: drawOptions,
      edit: editOptions
    }
    this.mapObject = new L.Control.Draw(options)
    L.drawLocal.draw.toolbar.actions.text = 'Annuler'
    L.drawLocal.draw.toolbar.actions.title = "Annule l'ajout"
    L.drawLocal.draw.toolbar.finish.text = 'Terminer'
    L.drawLocal.draw.toolbar.finish.title = "Termine l'ajout"
    L.drawLocal.draw.toolbar.undo.text = 'Supprimer dernier sommet'
    L.drawLocal.draw.toolbar.undo.title = 'Supprime le dernier sommet ajouté'
    L.drawLocal.draw.handlers.simpleshape.tooltip.end = 'Relâcher le bouton de la souris pour terminer'
    L.drawLocal.draw.toolbar.buttons.polyline = this.polylineTitle
    L.drawLocal.draw.toolbar.buttons.polygon = this.polygonTitle
    L.drawLocal.draw.toolbar.buttons.rectangle = this.rectangleTitle
    L.drawLocal.draw.toolbar.buttons.circle = this.circleTitle
    L.drawLocal.draw.toolbar.buttons.marker = this.markerTitle
    L.drawLocal.draw.toolbar.buttons.circleMarker = this.circleMarkerTitle
    L.drawLocal.draw.handlers.polyline.tooltip.start = this.polylineTooltipStart
    L.drawLocal.draw.handlers.polyline.tooltip.cont = this.polylineTooltipCont
    L.drawLocal.draw.handlers.polyline.tooltip.end = this.polylineTooltipEnd
    L.drawLocal.draw.handlers.polygon.tooltip.start = this.polygonTooltipStart
    L.drawLocal.draw.handlers.polygon.tooltip.cont = this.polygonTooltipCont
    L.drawLocal.draw.handlers.polygon.tooltip.end = this.polygonTooltipEnd
    L.drawLocal.draw.handlers.rectangle.tooltip.start = this.rectangleTooltip
    L.drawLocal.draw.handlers.circle.tooltip.start = this.circleTooltip
    L.drawLocal.draw.handlers.marker.tooltip.start = this.markerTooltip
    L.drawLocal.edit.toolbar.actions.save.title = 'Enregistrer les modifications'
    L.drawLocal.edit.toolbar.actions.save.text = 'Enregistrer'
    L.drawLocal.edit.toolbar.actions.cancel.title = 'Annuler, abandonner toutes les modifications'
    L.drawLocal.edit.toolbar.actions.cancel.text = 'Annuler'
    L.drawLocal.edit.toolbar.actions.clearAll.title = 'Effacer toutes les entités'
    L.drawLocal.edit.toolbar.actions.clearAll.text = 'Effacer tout'
    L.drawLocal.edit.toolbar.buttons.edit = this.editTitle
    L.drawLocal.edit.toolbar.buttons.editDisabled = 'Aucune entité à modifier'
    L.drawLocal.edit.toolbar.buttons.remove = this.removeTitle
    L.drawLocal.edit.toolbar.buttons.removeDisabled = 'Aucune entité à supprimer'
    L.drawLocal.edit.handlers.edit.tooltip.text = 'Faites glisser les marques pour modifier les entités'
    L.drawLocal.edit.handlers.edit.tooltip.subtext = 'Cliquer sur annuler pour revenir en arrière'
    L.drawLocal.edit.handlers.remove.tooltip.text = 'Cliquer sur une entité pour la supprimer'
    if (!this.removeAll) {
      L.EditToolbar.Delete.include({
        removeAllLayers: false
      })
    }
    if (this.$parent._isMounted) {
      this.deferredMountedTo(this.$parent.mapObject)
    }
  },
  methods: {
    deferredMountedTo (parent) {
      this.parent = parent
      parent.addControl(this.mapObject)
      for (var drawEvent of mapEvents) {
        parent.on(drawEvent, (ev) => {
          this.$parent.$emit(`l-${ev.type.replace(/:/g, '-')}`, ev)
        })
      }
      for (drawEvent of toolbarEvents) {
        parent.on(drawEvent, (ev) => {
          this.$emit(`l-${ev.type.replace(/:/g, '-')}`, ev)
        })
      }
    }
  }
}
</script>
