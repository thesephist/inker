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

        this.stdin = '';
        this.result = {
            exit: 0,
            error: null,
            output: '',
        };

        this.handleInput = this.handleInput.bind(this);
        this.requestEval = this.requestEval.bind(this);
    }

    handleInput(evt) {
        this.stdin = evt.target.value;
    }

    async requestEval() {
        this.result = await evalInk(this.stdin);
        this.render();
    }

    compose() {
        return jdom`<div class="iobox">
            <div class="inkInputBox">
                <textarea
                    class="inputBox"
                    oninput="${this.handleInput}"
                    value="${this.stdin}"/>
                <button class="runButton"
                    onclick="${this.requestEval}"
                    >run</button>
            </div>
            <div class="inkOutputBox">
                <pre>${this.result.output}</pre>
            </div>
        </div>`;
    }

}

class App extends StyledComponent {

    init() {
        this.ioBox = new IOBox();
    }

    compose() {
        return jdom`<main>
            Inker
            ${this.ioBox.node}
        </main>`;
    }

}

const app = new App();
document.getElementById('root').appendChild(app.node);
