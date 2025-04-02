import mongodb from "mongodb"

/**
 *
 * @param {mongodb.Document} doc
 */
export const serialize = doc => {
  return mongodb.BSON.EJSON.serialize(doc)
}

/**
 *
 * @param {Object} ejson
 */
export const _deserialize = ejson => {
  try {
    return mongodb.BSON.EJSON.deserialize(ejson)
  } catch (e) {
    return null
  }
}
