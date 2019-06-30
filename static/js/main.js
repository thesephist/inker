const {
    StyledComponent,
} = Torus;

async function evalInk(inkSource) {
    const resp = await fetch('/eval', {
        method: 'POST',
        headers: {
            'Content-Type': 'text/plain',
        },
        body: inkSource,
        cache: 'no-cache',
        credentials: 'same-origin',
    });
    return resp.json();
}

class IOBox extends StyledComponent {

    init() {
        this.waiting = false;
        this.showSaved = false;
        this.verticalSplit = window.innerWidth > 600;

        const lastSave = window.localStorage.getItem('ink_eval_save');
        this.stdin = lastSave || `out('Hello, World!')`;
        this.result = {
            exit: 0,
            error: null,
            output: 'click Run to see output...',
        };

        window.addEventListener('beforeunload', evt => {
            this.persistInput(false);
        });

        // TODO: also save every few seconds (10 seconds?) debounced

        this.persistInput = this.persistInput.bind(this);
        this.handleInput = this.handleInput.bind(this);
        this.handleKeydown = this.handleKeydown.bind(this);
        this.switchSplit = this.switchSplit.bind(this);
        this.requestEval = this.requestEval.bind(this);
    }

    persistInput(showBadge) {
        window.localStorage.setItem('ink_eval_save', this.stdin);
        if (showBadge === false) {
            return;
        }

        this.showSaved = true;
        this.render();
        setTimeout(() => {
            this.showSaved = false;
            this.render();
        }, 1200);
    }

    handleInput(evt) {
        this.stdin = evt.target.value;
    }

    handleKeydown(evt) {
        const ctrlCmd = evt.ctrlKey || evt.metaKey;
        if (evt.key === 'Enter' && ctrlCmd) {
            this.requestEval();
        } else if (evt.key.toLowerCase() === 's' && ctrlCmd) {
            evt.preventDefault();
            this.persistInput(true);
        }
    }

    switchSplit() {
        this.verticalSplit = !this.verticalSplit;
        this.render();
    }

    async requestEval() {
        this.waiting = true;
        this.render();

        this.result = await evalInk(this.stdin);
        this.waiting = false;
        this.render();
    }

    buttons() {
        return jdom`<div>
            <button
                class="block"
                onclick=${this.switchSplit}>Flip</button>
            <button
                class="block"
                onclick=${this.persistInput}>Save</button>
            <button
                class="accent block"
                onclick=${this.requestEval}>Run</button>
        </div>`;
    }

    styles() {
        return css`
        display: flex;
        flex-direction: ${this.verticalSplit ? 'row' : 'column'};
        justify-content: space-between;
        height: 0;
        flex-grow: 1;
        flex-shrink: 1;

        .inkInputBox,
        .inkOutputBox {
            width: 50%;
            box-sizing: border-box;
            position: relative;
        }
        .divider {
            background: #222;
            width: 3px;
            height: 100%;
        }
        &.flipped {
            .inkInputBox,
            .inkOutputBox {
                height: 50%;
                width: 100%;
            }
            .divider {
                width: 100%;
                height: 3px;
            }
            .savedBadge {
                top: 14px;
            }
        }

        textarea,
        .output {
            font-family: 'Dank Mono', 'Menlo', 'Monaco', monospace;
            font-size: 1em;
            box-sizing: border-box;
            padding: 12px 14px;
            background: transparent;
            resize: none;
            width: 100%;
            height: 100%;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            border: 0;
        }
        code {
            font-family: 'Dank Mono', 'Menlo', 'Monaco', monospace;
            display: block;
            font-size: 1em;
            line-height: 1.4em;
            margin-bottom: .6em;
        }
        .savedBadge {
            position: absolute;
            top: 12px;
            right: 12px;
            color: #555;
            transition: opacity .2s;

            &.hidden {
                opacity: 0;
            }
        }
        `;
    }

    compose() {
        return jdom`<div class="ioBox ${this.verticalSplit ? '' : 'flipped'}">
            <div class="inkInputBox">
                <textarea
                    class="inputBox"
                    oninput="${this.handleInput}"
                    onkeydown="${this.handleKeydown}"
                    placeholder="out('Hello, Ink!')"
                    value="${this.stdin}"/>
                <div class="savedBadge ${this.showSaved ? '' : 'hidden'}">
                    Saved to this device
                </div>
            </div>
            <div class="divider"></div>
            <div class="inkOutputBox">
                <div class="output">
                    ${this.waiting ?  'running...' :
                        this.result.output.split('\n')
                            .map(line => jdom`<code>${line}</code>`)}
                </div>
            </div>
        </div>`;
    }

}

class App extends StyledComponent {

    init() {
        this.ioBox = new IOBox();
    }

    styles() {
        return css`
        display: flex;
        flex-direction: column;
        height: 100vh;
        width: 100%;

        header {
            display: block;
            width: 100%;
            height: 36px;
            background: #222;
            color: #fff;
            padding: 8px 16px;
            justify-content: space-between;
            box-sizing: border-box;
            flex-grow: 0;

            &, .left, .right {
                display: flex;
                flex-direction: row;
                align-items: center;
            }
        }
        h1 {
            font-weight: normal;
            font-size: 1em;
            margin: 0;
        }
        .block {
            font-size: .9em;
            font-weight: normal;
            text-decoration: none;
            position: relative;
            top: 8px;
            padding: 3px 6px;
        }
        `;
    }

    compose() {
        return jdom`<main>
            <header>
                <div class="left">
                    <h1>Ink</h1>
                </div>
                <div class="right">
                    <a href="https://github.com/thesephist/ink"
                        rel="noopener noreferrer"
                        target="_blank"
                        class="block"
                        >About</a>
                    ${this.ioBox.buttons().children}
                </div>
            </header>
            ${this.ioBox.node}
        </main>`;
    }

}

const app = new App();
document.getElementById('root').appendChild(app.node);
