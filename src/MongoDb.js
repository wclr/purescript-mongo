"use strict";

//import { MongoClient as client } from "mongodb";
import mongodb from "mongodb";
const MongoClient = mongodb.MongoClient;

export const _connect = (uri, canceler, callback, left, right) => {
  handleP(
    MongoClient.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    }),
    callback,
    left,
    right
  );

  return canceler(MongoClient);
};

/**
 * @param {mongodb.MongoClient} client
 */
export const _defaultDb = (client) => {
  return client.db();
};

/**
 * @param {mongodb.MongoClient} client
 */
export const _db = (dbName, options, client) => {
  return client.db(dbName, options);
};

/**
 * @param {mongodb.MongoClient} client
 */
export const __db = (dbName, client) => {
  return client.db(dbName);
};

export const _handleParseFailure = (err, canceler, errback) => {
  process.nextTick(function () {
    errback(err)();
  });
  return canceler(MongoClient);
};

const handler = (callback, left, right) => (err, x) => {
  (err ? callback(left(err)) : callback(right(x)))();
};

const handleP = (p, callback, left, right) => {
  return p
    .then((x) => callback(right(x))())
    .catch((err) => callback(left(err))());
};

/**
 * @param {mongodb.MongoClient} client
 */
export const _close = function _close(client, canceler, callback, left, right) {
  handleP(client.close(), callback, left, right);
  return canceler({});
};

/**
 * @param {mongodb.Db} db
 */
export const _collection = (name, db, canceler, callback, left, right) => {
  //handleP(db.collection(name), callback, left, right);
  db.collection(name, handler(callback, left, right));
  return canceler(db);
};

/**
 * @param {mongodb.Db} db
 */
export const _dropCollection = (name, db, canceler, callback, left, right) => {
  handleP(db.dropCollection(name), callback, left, right);
  return canceler(db);
};

/**
 * @param {mongodb.Db} db
 */
export const _dropDatabase = (db, canceler, callback, left, right) => {
  handleP(db.dropDatabase, callback, left, right);
  return canceler(db);
};

/**
 * @param {mongodb.Cursor} cursor
 */
export const _collect = function _collect(
  cursor,
  canceler,
  callback,
  left,
  right
) {
  cursor.toArray(function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler(cursor);
};

/**
 * @param {mongodb.Cursor} cursor
 */
export const _collectOne = function _collectOne(
  cursor,
  canceler,
  callback,
  left,
  right
) {
  cursor.next(function (err, x) {
    if (err) {
      callback(left(err))();
    } else if (x === null) {
      var error = new Error("Not Found.");
      error.name = "MongoError";
      callback(left(error))();
    } else {
      callback(right(x))();
    }
  });
  return canceler(cursor);
};

/**
 * @param {mongodb.Collection} collection
 */
export const _findOne = function _findOne(
  selector,
  fields,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.findOne(selector, fields, function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler(collection);
};

/**
 * @param {mongodb.Collection} collection
 */
export const _createIndexes = (
  specs,
  collection,
  canceler,
  callback,
  left,
  right
) => {
  handleP(collection.createIndexes(specs), callback, left, right);

  return canceler(collection);
};

/**
 * @param {mongodb.Collection} collection
 */
export const _find = function _find(
  selector,
  fields,
  collection,
  canceler,
  callback,
  left,
  right
) {
  try {
    callback(right(collection.find(selector, fields)))();
  } catch (err) {
    callback(left(err))();
  }
  // collection.find(selector, fields, function (err, x) {
  //   (err ? callback(left(err)) : callback(right(x)))();
  // });
  return canceler(collection);
};

/**
 * @param {mongodb.Collection} collection
 */
export const _insertOne = function _insertOne(
  json,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.insertOne(json, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(
          right({ success: x.result.ok === 1, insertedId: x.insertedId })
        ))();
  });
  return canceler(collection);
};

/**
 * @param {mongodb.Collection} collection
 * @param {mongodb.ReplaceOneOptions} options
 */
export const _replaceOne = (
  query,
  json,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) => {
  handleP(collection.replaceOne(query, json, options), callback, left, (r) => {    
    //upsertedId: { index: 0, _id: 650d43ab5cf694bec9fbd599 } - if was upserted (doc not existed)
    return right({ success: r.result.ok === 1 });
  });

  return canceler(collection);
};

export const _insertMany = function _insertMany(
  json,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.insertMany(json, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(
          right({ success: x.result.ok === 1, insertedCount: x.insertedCount })
        ))();
  });
  return canceler(collection);
};

export const _updateOne = function (
  selector,
  json,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.updateOne(selector, { $set: json }, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(right({ success: x.result.ok === 1 })))();
  });

  return canceler(collection);
};

/**
 * @param {import("mongodb").Collection} collection
 */
export const _updateMany = function (
  selector,
  json,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.updateMany(selector, { $set: json }, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(right({ success: x.result.ok === 1 })))();
  });

  return canceler(collection);
};

// note that can not use arrow (=>) functions here
// because of: https://github.com/purescript/purescript/issues/4124
/**
 * @param {import("mongodb").Collection} collection
 */
export const _deleteOne = function (
  filter,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.deleteOne(filter, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(right({ success: x.result.ok === 1 })))();
  });
  return canceler(collection);
};

/**
 * @param {import("mongodb").Collection} collection
 */
export const _deleteMany = function (
  filter,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.deleteMany(filter, options, function (err, x) {
    (err
      ? callback(left(err))
      : callback(right({ success: x.result.ok === 1 })))();
  });
  return canceler(collection);
};

export const _countDocuments = function (
  selector,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection.countDocuments(selector, options, function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });

  return canceler(collection);
};

export const _aggregate = function (
  pipeline,
  options,
  collection,
  canceler,
  callback,
  left,
  right
) {
  collection["aggregate"](pipeline, options, function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });

  return canceler(collection);
};
