import mongodb from "mongodb"

/**
 * @typedef {{relaxed: boolean, useBigInt64: boolean}} Options
 */

/**
 * @param {Options} options
 * @param {mongodb.Document} doc
 */
export const _serialize = (options, doc) => {
  return mongodb.BSON.EJSON.serialize(doc, options)
}

/**
 *
 * @param {Options} options
 * @param {Object} ejson
 * @param {(e: unknown) => {result: true}} left
 * @param {(d: mongodb.Document) => {result: true}} right
 * @returns {{result: true}}
 */
export const _deserialize = (options, ejson, left, right) => {
  try {
    return right(mongodb.BSON.EJSON.deserialize(ejson, options))
  } catch (e) {
    return left(e)
  }
}
