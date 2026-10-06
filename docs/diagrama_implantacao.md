# Diagrama de Implantação — Homem Primitivo

> **Projeto:** Homem Primitivo - Projeto de Extensão  
> **Engine:** Godot 4.7  
> **Hospedagem:** GitHub Pages  

---

## Diagrama de Implantação

```mermaid
flowchart TB
    subgraph SERVER["«servidor web» GitHub Pages (HTTPS)"]
        direction TB
        HTML["index.html\n(Página de entrada)"]
        JS["index.js\n(Runtime Godot)"]
        WASM["index.wasm\n(Motor do jogo - WebAssembly)"]
        PCK["index.pck\n(Recursos do jogo empacotados)"]
        COI["coi-serviceworker.min.js\n(Service Worker)"]
    end

    subgraph CLIENT["«dispositivo» Computador do Jogador"]
        direction TB
        BROWSER["«ambiente de execução»\nNavegador Web"]
        WEBGL["WebGL 2.0\n(Renderização gráfica)"]
        WASMRT["WebAssembly\n(Execução do motor Godot)"]
        AUDIO["Web Audio API\n(Efeitos sonoros)"]
        CANVAS["HTML5 Canvas\n(Tela do jogo 1200×300)"]
        KB["Teclado\n(WASD, E, F, Espaço)"]

        BROWSER --> WEBGL
        BROWSER --> WASMRT
        BROWSER --> AUDIO
        BROWSER --> CANVAS
        KB -->|"Entrada do jogador"| BROWSER
    end

    SERVER -->|"HTTPS"| BROWSER
```

---

## Conteúdo do Pacote de Recursos (index.pck)

```mermaid
flowchart TD
    subgraph PCK["«artefato» index.pck"]
        direction TB
        CENAS["9 Cenas\n(Menu, Caverna, Floresta,\nLago, Vila, Conclusão...)"]
        SCRIPTS["25 Scripts GDScript\n(Player, GameManager,\nAudioManager, Portais...)"]
        SPRITES["~95 Sprites\n(Personagem, cenários,\nUI, NPCs, animais)"]
        SONS["5 Efeitos Sonoros\n(Pulo, ataque, dano,\ninteração, passos)"]
        FONTES["3 Fontes\n(Roboto, Celtica,\nPress Start 2P)"]
    end
```
