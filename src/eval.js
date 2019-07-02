const { spawn } = require('child_process');

const INKPATH = process.env.INKPATH || './bin/ink';

function evalInk(inkSource) {
    return new Promise((res, rej) => {
        // TODO: eventually, sandbox this with '--no-read --no-write --no-net (--no-exec?)'
        let output = '';
        const start = Date.now();
        const end = () => (Date.now() - start) / 1000;

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
            if (signal === 'SIGTERM') {
                res({
                    code,
                    error: 'process killed (timeout?)',
                    output: 'process killed (timeout?)',
                    duration: end(),
                });
            } else {
                res({
                    code,
                    error: null,
                    output,
                    duration: end(),
                });
            }
        });
        proc.once('error', err => {
            res({
                code: 1,
                error: err,
                output: output + '\n' + err,
                duration: end(),
            })
        });

        proc.stdin.write(inkSource);
        proc.stdin.end();

        setTimeout(() => {
            proc.kill('SIGTERM');
            // 20s is current timeout
        }, 20 * 1000);
    });
}

module.exports = {
    evalInk,
}
