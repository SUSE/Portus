require('jsdom-global')();

const dayjs = require('dayjs');
const relativeTime = require('dayjs/plugin/relativeTime');

global.expect = require('expect');

dayjs.extend(relativeTime);
