const {
    StyledComponent,
}

class App extends StyledComponent {

    compose() {
        return jdom`<main>Inker</main>`;
    }

}

const app = new App();
document.getElementById('root').appendChild(app.node);
