const { spawn } = require('child_process');

const INKPATH = process.env.INKPATH || 'ink';

function evalInk(inkSource) {
    return new Promise((res, rej) => {
        // TODO: eventually, sandbox this with '--no-read --no-write --no-net (--no-exec?)'
        let output = '';
        const proc = spawn(`${INKPATH}`, [], {
            stdio: 'pipe',
        });
        // TODO: what if we HTTP stream this output instead? ~~Node.js Streams~~
        proc.stdout.on('data', data => {
            output += data;
        });
        proc.stderr.on('data', data => {
            output += data;
        });

        proc.once('close', (code, signal) => {
            res({
                code,
                error: null,
                output,
            });
        });
        proc.once('error', err => {
            res({
                code: 1,
                error: err,
                output,
            })
        });

        proc.stdin.write(inkSource);
        proc.stdin.end();
    });
}

module.exports = {
    evalInk,
}
