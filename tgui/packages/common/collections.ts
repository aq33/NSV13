/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const binarySearch = <T, U = unknown>(
  getKey: (value: T) => U,
  collection: readonly T[],
  inserting: T,
): number => {
  if (collection.length === 0) {
    return 0;
  }

  const insertingKey = getKey(inserting);

  let [low, high] = [0, collection.length];

  // Because we have checked if the collection is empty, it's impossible
  // for this to be used before assignment.
  let compare: U = undefined as unknown as U;
  let middle = 0;

  while (low < high) {
    middle = (low + high) >> 1;

    compare = getKey(collection[middle]);

    if (compare < insertingKey) {
      low = middle + 1;
    } else if (compare === insertingKey) {
      return middle;
    } else {
      high = middle;
    }
  }

  return compare > insertingKey ? middle : middle + 1;
};

export const binaryInsertWith = <T, U = unknown>(
  collection: readonly T[],
  value: T,
  getKey: (value: T) => U,
): T[] => {
  const copy = [...collection];
  copy.splice(binarySearch(getKey, collection, value), 0, value);
  return copy;
};

// Needed by Fabricator.tsx
const COMPARATOR = (objA, objB) => {
  const criteriaA = objA.criteria;
  const criteriaB = objB.criteria;
  const length = criteriaA.length;
  for (let i = 0; i < length; i++) {
    const a = criteriaA[i];
    const b = criteriaB[i];
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
  }
  return 0;
};

/**
 * Creates an array of elements, sorted in ascending order by the results
 * of running each element in a collection thru each iteratee.
 *
 * Iteratees are called with one argument (value).
 */
export const sortBy =
  <T = any>(...iterateeFns: ((input: T) => unknown)[]) =>
  (array: T[]): T[] => {
    if (!Array.isArray(array)) {
      return array;
    }
    let length = array.length;
    // Iterate over the array to collect criteria to sort it by
    let mappedArray: {
      criteria: unknown[];
      value: T;
    }[] = [];
    for (let i = 0; i < length; i++) {
      const value = array[i];
      mappedArray.push({
        criteria: iterateeFns.map((fn) => fn(value)),
        value,
      });
    }
    // Sort criteria using the base comparator
    mappedArray.sort(COMPARATOR);

    // Unwrap values
    const values: T[] = [];
    while (length--) {
      values[length] = mappedArray[length].value;
    }
    return values;
  };

// AQUILA: curried helpers from our pre-React tgui (removed upstream in BeeStation#14299),
// kept because our interfaces still use them. They work on arrays and on DM assoc lists (objects).

/**
 * Converts a given collection to an array.
 *
 * - Arrays are returned unmodified;
 * - If object was provided, keys will be discarded;
 * - Everything else will result in an empty array.
 */
export const toArray = (collection: any): any[] => {
  if (Array.isArray(collection)) {
    return collection;
  }
  if (collection && typeof collection === 'object') {
    return Object.keys(collection).map((key) => collection[key]);
  }
  return [];
};

/**
 * Iterates over elements of collection, returning an array of all elements
 * iteratee returns truthy for. If collection is null or undefined, it is returned as is.
 */
export const filter =
  <T = any>(iterateeFn: (input: T, index: number, collection: T[]) => any) =>
  (collection: T[]): T[] => {
    if (collection === null || collection === undefined) {
      return collection;
    }
    if (Array.isArray(collection)) {
      return collection.filter((item, i) => iterateeFn(item, i, collection));
    }
    throw new Error(`filter() can't iterate on type ${typeof collection}`);
  };

/**
 * Creates an array of values by running each element in collection
 * thru an iteratee function: (value, index|key, collection).
 */
export const map =
  <T = any, R = any>(iterateeFn: (value: T, key: any, collection: any) => R) =>
  (collection: any): R[] => {
    if (collection === null || collection === undefined) {
      return collection;
    }
    if (Array.isArray(collection)) {
      return collection.map((item, i) => iterateeFn(item, i, collection));
    }
    if (typeof collection === 'object') {
      return Object.keys(collection).map((key) =>
        iterateeFn(collection[key], key, collection),
      );
    }
    throw new Error(`map() can't iterate on type ${typeof collection}`);
  };

/**
 * Returns a range of numbers from start to end, exclusively.
 * For example, range(0, 5) will return [0, 1, 2, 3, 4].
 */
export const range = (start: number, end: number): number[] =>
  new Array(end - start).fill(null).map((_, index) => index + start);

/**
 * Creates a duplicate-free version of an array, keeping the first occurrence
 * of every value (or of every value of iterateeFn).
 */
export const uniqBy =
  <T = any>(iterateeFn?: (value: T) => unknown) =>
  (array: T[]): T[] => {
    const seen = new Set<unknown>();
    const result: T[] = [];
    for (const value of array) {
      const computed = iterateeFn ? iterateeFn(value) : value;
      if (!seen.has(computed)) {
        seen.add(computed);
        result.push(value);
      }
    }
    return result;
  };
