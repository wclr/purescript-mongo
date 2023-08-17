"use strict";

//import { MongoClient as client } from "mongodb";
import mongodb from "mongodb";
const client = mongodb.MongoClient

export const _connect = function _connect(uri, canceler, callback, left, right) {
  client.connect(
    uri,
    { useNewUrlParser: true, useUnifiedTopology: true },
    function (err, x) {
      if (err) {
        return callback(left(err))();
      }

      return callback(right(x))();
    }
  );

  return canceler(client);
};

export const _defaultDb = function _defaultDb(client) {
  return client.db();
};

export const _db = function _defaultDb(dbName, options, client) {
  return client.db(dbName, options);
};

export const __db = function _defaultDb(dbName, client) {
  return client.db(dbName);
};

export const _handleParseFailure = function _handleParseFailure(
  err,
  canceler,
  errback
) {
  process.nextTick(function () {
    errback(err)();
  });  
  return canceler(client);
};


export const _close = function _close(client, canceler, callback, left, right) {
  client.close(function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler({});
};


export const _collection = function _collection(
  name,
  db,
  canceler,
  callback,
  left,
  right
) {
  db.collection(name, function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler(db);
};

export const _collect = function _collect(cursor, canceler, callback, left, right) {
  cursor.toArray(function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler(cursor);
};

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
 * @param {import("mongodb").Collection} collection
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
 * @param {import("mongodb").Collection} collection
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
