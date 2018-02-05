// generates a range of integers
export default (start, end) => {
  if (start > end) {
    throw new Error('Range: "start" cannot be greater than "end"');
  }

  return Array.from({ length: (end - start) + 1 }, (_, i) => i + start);
};
