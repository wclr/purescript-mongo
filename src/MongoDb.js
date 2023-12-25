import mongodb from "mongodb"

/**
 * @template T
 * @typedef {() => T} Effect<T>
 */

/**
 * @param {String} uri
 * @returns {Effect<Promise<mongodb.MongoClient>>}
 */
export const _connect = uri => {
  return () => mongodb.MongoClient.connect(uri)
}

/**
 * @param {mongodb.MongoClient} client
 * @returns {Effect<mongodb.Db>}
 */
export const _defaultDb = client => {
  return () => client.db()
}

/**
 * @param {mongodb.MongoClient} client
 * @param {string} dbName
 * @returns {Effect<mongodb.Db>}
 */
export const _db = (client, dbName) => {
  return () => client.db(dbName)
}

/**
 * @param {mongodb.MongoClient} client
 * @returns {Effect<Promise<void>>}
 */
export const _close = function _close(client) {
  return () => client.close()
}

/**
 * @param {mongodb.Db} db
 * @returns {Effect<mongodb.Collection>}
 */
export const _collection = (db, name) => {
  return () => db.collection(name)
}

/**
 * @param {mongodb.Db} db
 * @param {string} db
 * @returns {Effect<Promise<boolean>>}
 */
export const _dropCollection = (db, name) => {
  return () => db.dropCollection(name)
}

/**
 * @param {mongodb.Db} db
 * @returns {Effect<Promise<boolean>>}
 */
export const _dropDatabase = db => {
  return () => db.dropDatabase()
}

/**
 * @param {mongodb.Db} db
 * @returns {string}
 */
export const databaseName = db => {
  return db.databaseName
}

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.IndexDescription[]} indexSpecs
 * @returns {Effect<Promise<string[]>>}
 */
export const _createIndexes = (collection, indexSpecs) => {
  return () => collection.createIndexes(indexSpecs)
}

/**
 * @typedef {Object} CountDocumentOptions
 *
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any>} filter
 * @param {CountDocumentOptions | null} options
 * @returns {Effect<Promise<number>>}
 */
export const _countDocuments = (collection, filter, options) => {
  return () => collection.countDocuments(filter, options)
}

/**
 * @typedef {Object} FindOptions
 * @property {number | null} limit
 * @property {number | null} skip
 * @property {Object | null} sort
 * @property {Object | null} projection
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any>} filter
 * @param {FindOptions | null} options
 * @returns {Effect<Promise<mongodb.Document>>}
 */
export const _findOne = (collection, filter, options) => {
  return () => collection.findOne(filter, options)
}

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any> | null} filter
 * @param {FindOptions | null} options
 * @returns {Effect<mongodb.FindCursor>}
 */
export const _find = (collection, filter, options) => {
  return () => collection.find(filter, options)
}

/**
 * @param {mongodb.FindCursor} cursor
 * @returns {Effect<Promise<Array<mongodb.Document>>>}
 */
export const _cursorToArray = cursor => {
  return () => cursor.toArray()
}

/**
 * @param {mongodb.FindCursor} cursor
 * @returns {Effect<Promise<mongodb.Document | null>>}
 */
export const _cursorNext = cursor => {
  return () => cursor.next()
}

/**
 * @typedef {Object} InsertOneOptions
 * 
 * 
 * @typedef {Object} InsertOneResult
 * @property { Boolean} acknowledged
   @property {Object} insertedId
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Document} doc
 * @param {InsertOneOptions | null} options
 * @returns {Effect<Promise<InsertOneResult>>}
 */
export const _insertOne = (collection, doc, options) => {
  return () => collection.insertOne(doc, options)
}

/**
 * @typedef {Object} ReplaceOptions
 * @property {boolean} upsert
 */

/**
 * @typedef {Object} UpdateResult
 * @property {boolean} acknowledged
 * @property {number} matchedCount
 * @property {number} modifiedCount
 * @property {number} upsertedCount
 * @property {number | null} upsertedId
 *
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<Document>} doc
 * @param {mongodb.Document} doc
 * @param {ReplaceOptions | null} options
 * This is probably a mistake in typings that it may return Document
 * @returns {Effect<Promise<mongodb.UpdateResult | mongodb.Document>>}
 */
export const _replaceOne = (collection, filter, doc, options) => {
  return () => collection.replaceOne(filter, doc, options)
}
