pragma Singleton

// ==========================================================
// Громкость через нативный сервис Quickshell (PipeWire).
// PwObjectTracker обязателен: без него узел остаётся
// "unbound" — volume/muted читаются нулём, а запись падает
// с ошибкой "which is not bound".
// ==========================================================

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    readonly property var node: Pipewire.defaultAudioSink
    readonly property var audio: node ? node.audio : null

    readonly property bool available: node !== null && audio !== null
    readonly property bool muted: audio ? audio.muted : false
    readonly property real volume: audio ? audio.volume : 0
    readonly property int percent: Math.round(volume * 100)
    readonly property string description: node
        ? (node.description !== "" ? node.description : node.name)
        : ""

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function clamp(v, min, max) {
        return Math.max(min, Math.min(max, v))
    }

    function setFraction(v) {
        if (!audio)
            return
        const value = clamp(v, 0, 1)
        audio.volume = value
        if (value > 0 && audio.muted)
            audio.muted = false
    }

    function setPercent(p) {
        setFraction(p / 100)
    }

    function step(deltaPercent) {
        setPercent(percent + deltaPercent)
    }

    function toggleMute() {
        if (audio)
            audio.muted = !audio.muted
    }
}
