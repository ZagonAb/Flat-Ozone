import QtQuick 2.15

Item {
    id: themeSettings

    property int currentThemeIndex: 0

    readonly property string bgColor: _current.bg
    readonly property string surfaceColor: _current.surface
    readonly property string highlightColor: _current.highlight
    readonly property string textPrimary: _current.textPrimary
    readonly property string textSecondary: _current.textSecondary
    readonly property string accentColor: _current.accent
    readonly property string separatorColor: _current.separator
    readonly property string themeName: _current.name

    readonly property var themes: [
        {
            name: "Gris oscuro",
            bg: "#0e0e0e",
            surface: "#1a1a1a",
            highlight: "#303030",
            textPrimary: "#ffffff",
            textSecondary: "#c0c0c0",
            accent: "#ffffff",
            separator: "#2c2c2c"
        },
        {
            name: "Gris claro",
            bg: "#d0d0d0",
            surface: "#e8e8e8",
            highlight: "#b0b0b0",
            textPrimary: "#111111",
            textSecondary: "#333333",
            accent: "#222222",
            separator: "#aaaaaa"
        },
        {
            name: "Blanco básico",
            bg: "#f5f5f5",
            surface: "#ffffff",
            highlight: "#e0e0e0",
            textPrimary: "#000000",
            textSecondary: "#444444",
            accent: "#000000",
            separator: "#cccccc"
        },
        {
            name: "Negro básico",
            bg: "#000000",
            surface: "#0a0a0a",
            highlight: "#1c1c1c",
            textPrimary: "#f0f0f0",
            textSecondary: "#a0a0a0",
            accent: "#f0f0f0",
            separator: "#1a1a1a"
        },
        {
            name: "Nórdico",
            bg: "#2e3440",
            surface: "#3b4252",
            highlight: "#434c5e",
            textPrimary: "#eceff4",
            textSecondary: "#d8dee9",
            accent: "#88c0d0",
            separator: "#4c566a"
        },
        {
            name: "Gruvbox (oscuro)",
            bg: "#282828",
            surface: "#3c3836",
            highlight: "#504945",
            textPrimary: "#ebdbb2",
            textSecondary: "#d5c4a1",
            accent: "#fabd2f",
            separator: "#504945"
        },
        {
            name: "Boysenberry",
            bg: "#1f0a2a",
            surface: "#2d1040",
            highlight: "#4a1f6a",
            textPrimary: "#f0d6ff",
            textSecondary: "#c9a0dc",
            accent: "#da70d6",
            separator: "#3d155a"
        },
        {
            name: "Hackeando el kernel",
            bg: "#0d0d0d",
            surface: "#111111",
            highlight: "#003300",
            textPrimary: "#00ff41",
            textSecondary: "#00cc33",
            accent: "#00ff41",
            separator: "#003300"
        },
        {
            name: "Twilight Zone",
            bg: "#0a0a1a",
            surface: "#12122a",
            highlight: "#1e1e4a",
            textPrimary: "#c8c8ff",
            textSecondary: "#9090cc",
            accent: "#7070dd",
            separator: "#1a1a3a"
        },
        {
            name: "Drácula",
            bg: "#282a36",
            surface: "#343746",
            highlight: "#44475a",
            textPrimary: "#f8f8f2",
            textSecondary: "#6272a4",
            accent: "#bd93f9",
            separator: "#44475a"
        },
        {
            name: "Solarizado (oscuro)",
            bg: "#002b36",
            surface: "#073642",
            highlight: "#0a4a5a",
            textPrimary: "#fdf6e3",
            textSecondary: "#839496",
            accent: "#268bd2",
            separator: "#073642"
        },
        {
            name: "Solarizado (claro)",
            bg: "#fdf6e3",
            surface: "#eee8d5",
            highlight: "#d0c8b0",
            textPrimary: "#657b83",
            textSecondary: "#839496",
            accent: "#268bd2",
            separator: "#d0c8b0"
        },
        {
            name: "Lluvia violeta",
            bg: "#1a0a2e",
            surface: "#2a1045",
            highlight: "#3d1a60",
            textPrimary: "#e8d5f0",
            textSecondary: "#b08ac0",
            accent: "#9b59b6",
            separator: "#3a1558"
        },
        {
            name: "Selenio",
            bg: "#1c1c24",
            surface: "#25252f",
            highlight: "#35354a",
            textPrimary: "#d0d0e8",
            textSecondary: "#8080a0",
            accent: "#7b7bca",
            separator: "#2e2e40"
        }
    ]

    readonly property var _current: themes[currentThemeIndex] || themes[0]

    Component.onCompleted: {
        var saved = api.memory.get("themeColorIndex");
        if (saved !== undefined && saved >= 0 && saved < themes.length)
            currentThemeIndex = saved;
    }

    function applyTheme(index) {
        if (index >= 0 && index < themes.length) {
            currentThemeIndex = index;
            api.memory.set("themeColorIndex", index);
        }
    }
}
