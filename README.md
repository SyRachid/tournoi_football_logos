
# Tournoi Football (Flutter)

Jeu de tournoi 8 équipes (Quarts → Demis → Finale → Champion). Choix 1–4 joueurs, le reste IA. Scores aléatoires, progression automatique.

## ⚙️ Prérequis
- Flutter SDK installé (3.x)
- Android Studio ou SDK Android installé
- Un appareil Android ou un émulateur

## ▶️ Lancer en debug
```bash
flutter pub get
flutter run
```

## 📦 Générer l'APK (Android)
```bash
flutter build apk --release
# L'APK est ici :
# build/app/outputs/flutter-apk/app-release.apk
```

## 🧱 Structure
- `lib/main.dart` : toute la logique du jeu
- Pas d'assets externes (logos générés via couleurs & initiales)

## 🕹️ Gameplay
1. Choisir le nombre de joueurs (1–4).
2. Cliquer pour tirer une équipe pour chaque joueur.
3. Cliquer sur **Remplir IA & Commencer**.
4. Cliquer **Suivant** pour simuler chaque tour jusqu'au Champion.
5. Bouton 🔄 pour réinitialiser.

Bon match ! ⚽
