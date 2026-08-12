import { strict as assert } from 'node:assert';
import { createReasoningEngine, type ReasoningContext } from './reasoning_context.ts';

const originalEntries = [{ kind: 'context', value: 'bounded' }];
const context: ReasoningContext = {
  identity: { sh_id: 'sh-test' },
  user_message: 'hello',
  entries: originalEntries,
};

let received: ReasoningContext | undefined;
let calls = 0;

const engine = createReasoningEngine({
  async generate(input) {
    calls += 1;
    received = input;
    return { output: 'ok' };
  },
});

const result = await engine.process({ context });

assert.equal(calls, 1);
assert.equal(result.output, 'ok');
assert.equal(received?.identity.sh_id, 'sh-test');
assert.equal(received?.user_message, 'hello');
assert.deepEqual(received?.entries, originalEntries);
assert.notEqual(received?.entries, originalEntries);
assert(Object.isFrozen(received));
assert(Object.isFrozen(received?.identity));
assert(Object.isFrozen(received?.entries));
assert.equal(Object.prototype.hasOwnProperty.call(received, 'memory'), false);
assert.equal(Object.prototype.hasOwnProperty.call(received, 'knowledge'), false);

console.log('P4B-001 reasoning context integration/isolation: PASS');
