import Vue from 'vue'
import axios from 'axios'

export default {
  install (vue) {
    Vue.prototype.$get = $get
    Vue.prototype.$post = $post
  }
}

export async function $get (url) {
  try {
    const response = await axios.get(url)
    return response
  } catch (e) {
    throw e
  }
}

export async function $post (url, data, metadata) {
  try {
    const response = await axios.post(url, data, metadata)
    return response
  } catch (e) {
    throw e
  }
}

export async function $put (url, data, metadata) {
  try {
    const response = await axios.put(url, data, metadata)
    return response
  } catch (e) {
    throw e
  }
}
