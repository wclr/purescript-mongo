import mongodb from "mongodb"

/**
 * @template T
 * @typedef {() => T} Effect<T>
 *
 */

/**
 * * @typedef {mongodb.Filter<any>} Filter
 */

/**
 *  @typedef {Object} CommonOptions
 *  @property {mongodb.ClientSession | null} session
 */

/**
 *
 * @param {CommonOptions} opts
 * @returns
 */
const getCommonOpts = opts => {
  return {
    session: opts.session || undefined,
  }
}

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
 * @param {null} options
 * @returns {Effect<mongodb.ClientSession>}
 */
export const _startSession = (client, options) => {
  const options_ = options ? {} : undefined

  return () => client.startSession(options_)
}

/**
 * @param {mongodb.ClientSession} session
 * @param {null} options
 * @returns {Effect<Promise<void>>}
 */
export const _endSession = (session, options) => {
  const options_ = options ? {} : undefined
  return () => session.endSession(options_)
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
 * @param {string} name
 * @returns {Effect<mongodb.Collection>}
 */
export const _collection = (db, name) => {
  return () => db.collection(name)
}

/**
 * @param {mongodb.Db} db
 * @param {string} name
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
 * @typedef {Object} CountDocumentsOptions
 * @property {number | null} limit
 * @property {number | null} skip
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any>} filter
 * @param {CountDocumentsOptions | null} options
 * @returns {Effect<Promise<number>>}
 */
export const _countDocuments = (collection, filter, options) => {
  const options_ = options
    ? {
        limit: options.limit || undefined,
        skip: options.skip || undefined,
      }
    : undefined
  return () => collection.countDocuments(filter, options_)
}

/**
 * @typedef {Object} FindOptions
 * @property {number | null} limit
 * @property {number | null} skip
 * @property {{[k: string]: 1 | -1} | null} sort
 * @property {Object | null} projection
 */

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any>} filter
 * @param {FindOptions & CommonOptions | null} options
 * @returns {Effect<Promise<mongodb.Document | null>>}
 */
export const _findOne = (collection, filter, options) => {
  const options_ = options
    ? {
        limit: options.limit || undefined,
        skip: options.skip || undefined,
        sort: options.sort || undefined,
        projection: options.projection || undefined,
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.findOne(filter, options_)
}

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Filter<any>} filter
 * @param {FindOptions & CommonOptions | null} options
 * @returns {Effect<mongodb.FindCursor>}
 */
export const _find = (collection, filter, options) => {
  const options_ = options
    ? {
        limit: options.limit || undefined,
        skip: options.skip || undefined,
        sort: options.sort || undefined,
        projection: options.projection || undefined,
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.find(filter, options_)
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
 * @typedef {CommonOptions} InsertOneOptions
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
  const options_ = options ? getCommonOpts(options) : undefined
  return () => collection.insertOne(doc, options_)
}

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.Document[]} docs
 * @param {CommonOptions | null} options
 * @returns {Effect<Promise<mongodb.InsertManyResult>>}
 */
export const _insertMany = (collection, docs, options) => {
  const _options = options ? getCommonOpts(options) : undefined
  return () => collection.insertMany(docs, _options)
}
/**
 * @typedef {Object} ReplaceOptions
 * @property {boolean | null } upsert
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
 * @param {Filter} filter
 * @param {mongodb.Document} doc
 * @param {ReplaceOptions & CommonOptions | null} options
 * This is probably a mistake in typings that it may return Document
 * @returns {Effect<Promise<mongodb.UpdateResult | mongodb.Document>>}
 */
export const _replaceOne = (collection, filter, doc, options) => {
  const options_ = options
    ? {
        upsert: options.upsert || undefined,
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.replaceOne(filter, doc, options_)
}

/**
 * @typedef {Object} UpdateFilter
 */

/**
 * @typedef {Object} UpdateOptions
 * @property {boolean | null } upsert
 */

/**
 * @param {mongodb.Collection} collection
 * @param {Filter} filter
 * @param {UpdateFilter } update
 * @param {UpdateOptions & CommonOptions | null} options
 * @returns {Effect<Promise<UpdateResult> | mongodb.Document>}
 */
export const _updateOne = (collection, filter, update, options) => {
  const options_ = options
    ? {
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.updateOne(filter, update, options_)
}

/**
 * @param {mongodb.Collection} collection
 * @param {Filter} filter
 * @param {UpdateFilter } update
 * @param {DeleteOptions & CommonOptions | null} options
 * @returns {Effect<Promise<UpdateResult> | mongodb.Document>}
 */
export const _updateMany = (collection, filter, update, options) => {
  const options_ = options
    ? {
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.updateMany(filter, update, options_)
}

/**
 * @typedef {Object} DeleteOptions
 *
 */

/**
 * @typedef {Object} DeleteResult
 * @property {boolean} acknowledged
 * @property {number} deletedCount
 */

/**
 * @param {mongodb.Collection} collection
 * @param {Filter} filter
 * @param {DeleteOptions & CommonOptions | null} options
 * @returns {Effect<Promise<DeleteResult>>}
 */
export const _deleteOne = (collection, filter, options) => {
  const options_ = options
    ? {
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.deleteOne(filter, options_)
}

/**
 * @param {mongodb.Collection} collection
 * @param {Filter} filter
 * @param {DeleteOptions & CommonOptions | null} options
 * @returns {Effect<Promise<DeleteResult>>}
 */
export const _deleteMany = (collection, filter, options) => {
  const options_ = options
    ? {
        ...getCommonOpts(options),
      }
    : undefined
  return () => collection.deleteMany(filter, options_)
}

/**
 *
 * @param {mongodb.ClientSession} session
 * @param {Effect <Promise<void>>} action
 * @param {null} options
 * @returns {Effect<Promise<void>>}
 */
export const _withTransaction = (session, action, options) => {
  return () => {
    const options_ = options ? {} : undefined

    return session.withTransaction(() => {
      return action()
    }, options_)
  }
}
