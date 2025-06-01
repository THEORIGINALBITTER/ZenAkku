# Zen Akku

**Zen Akku** ist eine elegante macOS-App, geschrieben in SwiftUI, die auf einen Blick Ladezustand, SSD- und RAM-Auslastung anzeigt – im Wabi-Sabi-Stil. Das Design verzichtet auf überflüssige Elemente, setzt auf reduzierte, natürliche Ästhetik und liefert trotzdem alle wichtigen Informationen kompakt zusammengefasst.

---

## Inhaltsverzeichnis

1. [Projektbeschreibung](#projektbeschreibung)  
2. [Funktionen](#funktionen)  
3. [Voraussetzungen](#voraussetzungen)  
4. [Installation & Build](#installation--build)  
5. [Verwendung](#verwendung)  
6. [SwiftUI-Preview und Mock-Daten](#swiftui-preview-und-mock-daten)  
7. [Bekannte Einschränkungen](#bekannte-einschränkungen)  
8. [Ordnerstruktur](#ordnerstruktur)  
9. [Lizenz](#lizenz)

---

## Projektbeschreibung

*Zen Akku* ist inspiriert vom Wabi-Sabi-Gedanken: Weniger ist mehr, Unvollkommenheit wird zelebriert. Anstelle komplexer Diagramme oder Tabellen zeigt *Zen Akku*:

- Einen pulsierenden **Batterie-Ring**, der den aktuellen Akkuladestand darstellt  
- Zwei weitere Ringe für **SSD-Auslastung** und **RAM-Verbrauch**  
- Eine **Top-Bar**, die links das Batterieladesymbol und –text („Akku • ON“ oder „Netzteil • ON“) anzeigt und rechts den prozentualen Ladezustand  
- Unterhalb eine **Grid-Liste** mit Detailwerten (Ladezeit oder Restlaufzeit, belegter/freier SSD-Speicher, belegter/freier RAM)  
- Buttons, um manuell zu **aktualisieren** oder den **Cache zu bereinigen**  
- Ein zufälliges Zitat in monospaced Schrift, um die minimalistische Optik abzurunden  

Alle Werte liest *Zen Akku* über die integrierten Frameworks (IOKit.ps für Power-Infos, FileManager für Dateisystem-Attribute, sysctl/VM-Statistiken für RAM-Daten) aus. Die App aktualisiert sich automatisch alle 5 Sekunden über einen Timer und reagiert auf das Ein- und Ausstecken des Netzteils mit einer dezenten Puls-Animation im Batterie-Ring.

---

## Funktionen

- **Echtzeit-Battery-Status**  
  - Zeigt aktuellen Ladezustand (0 – 100 %)  
  - Erkennt, ob Netzteil angeschlossen ist, und wechselt dynamisch zwischen „Akku • ON“ und „Netzteil • ON“  
  - Ermittelt verbleibende Lade-/Entlade-Zeit in „HH:MM“-Format  

- **SSD-Status**  
  - Misst belegten und freien Speicher (in GB)  
  - Zeigt prozentuale Auslastung in einem Wabi-Ring  

- **RAM-Status**  
  - Ermittelt belegten und freien Arbeitsspeicher (in GB)  
  - Zeigt prozentuale Auslastung in einem Wabi-Ring  

- **Wabi-Sabi-Rings**  
  - Drei animierte Ringe: Batterie (gelb), SSD (grün) und RAM (weiß)  
  - Variierende Strichstärken für ein „handgemachtes“ Gefühl  
  - Pulsierende Animation, wenn das Netzteil angeschlossen ist  

- **Zufalls-Zitat**  
  - Monospaced, leicht transparent  
  - Jedes Zitat stammt aus `QuoteProvider` und wird je nach Stunde des Tages ausgewählt  

- **Detail-Grid**  
  - Listet in wenigen Zeilen: Ladezeit, SSD-Belegt/Frei, RAM-Belegt/Frei  
  - Farbige Hervorhebung (rot für Belegt, grün für Frei)  

- **Buttons**  
  - „Aktualisieren“: Manuelle Auslösung von `refreshAll()`  
  - „Cache bereinigen“: Löscht temporäre Caches (`~/Library/Caches`), aktualisiert anschließend die Daten  

---

## Voraussetzungen

- macOS 12.0 oder neuer  
- Xcode 14.0 oder neuer  
- Swift 5.7 (oder aktueller)  
- SwiftUI, Combine, IOKit, MachO, sysctl, vm_statistics64  

Wenn du auf deinem Mac ein Apple Silicon-Gerät (M1, M2, etc.) hast, kannst du die Preview in Xcode nutzen – die App liest den echten Ladezustand dann aber nur im echten Laufzeit-Modus (⌘ R). In der Canvas-Preview erhältst du standardmäßig Mock-Daten, weil in der Sandbox keine echten PowerSources existieren.

---

## Installation & Build

1. **Repository klonen**  
   ```bash
   git clone https://github.com/theoriginalbitter/ZenAkku.git
   cd ZenAkku
