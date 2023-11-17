### BASIS Vorlesungsverzeichnis App
# App Backend

The unofficial app of the BASIS lecture directory of the University of Bonn.

<a href="https://play.google.com/store/apps/details?id=com.miguelcz.stmg_app"><img src="https://img.shields.io/badge/Version-1.0.1-green?style=for-the-badge" alt="version"></a>
<a href=""><img src="https://img.shields.io/badge/rating-5/5-green?style=for-the-badge" alt="rating"/></a>

<a href="https://play.google.com/store/apps/details?id=com.miguelcz.basis"><img alt="Jetzt bei Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/de_badge_web_generic.png" height="60"/></a>
<a href="https://apps.apple.com/de/app/basis-vorlesungsverzeichnis/id6470085783"><img alt="Jetzt bei Apple Store" src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="60" width="140"/></a>

<!--
 | <img src="https://play-lh.googleusercontent.com/HE61X_Dhma2WoG_-U7QSX_Lv3oxodgmgkL28EIhil9CcQHUI-YnB3hf-GcVfSZ4tQg=w1920-h564" alt="Screenshot" /> | <img src="https://play-lh.googleusercontent.com/4FaBhNGEenVfgc0MGpPDcoLH44JChvzLKm6guSD_fSbuyLfzKWA1Hw7xGNvlNn0OVusL=w1920-h564" alt="Screenshot" /> | <img src="https://play-lh.googleusercontent.com/YM4gg7ihERLPXWbh4umfh3WzaXt2AZUgRpWCkKJdR0xZzkB0Zdub2snc3CuhCNh4fro=w1920-h564" alt="Screenshot" /> |
| --- | --- | --- |
-->

## Motivation

Hey! We, a team of students from the University of Bonn, know the struggle with the unwieldy and old-fashioned BASIS website.
That's why we created the BASIS app - a simple, stylish and user-friendly solution to quickly navigate through the course catalog.

### Quick overview

- All the information you need, compact and no frills.

### Always up to date

- Choose your semester and keep an eye on all courses and events. No mess, no stress.

### By students, for students

- We built it ourselves because we know exactly what's annoying. Expect intuitive operation, clearly structured information and a design that doesn't come from the Stone Age.


## About this repository

Our app is built with [Flutter](https://flutter.dev/), a cross-platform framework for building mobile apps. This repository contains the source code of the app's backend, which is written in [Dart](https://dart.dev/). Until now, only the backend is open source, but we are planning to open source the frontend as well.

## Project structure

A typical Flutter project looks like this:

```
app_name            (root project folder)
    ios/            (iOS app configuration)
    android/        (Android app configuration)
    assets/         (Static files like images)
    lib/            (Dart code)
    pubspec.yaml    (Dependency and framework configuration file)
```
Now let's take a closer look at our `lib/` folder:

```
lib
    main.dart               (Entry point of the app)
    core/                   (Core logic of the app)
        data/               (Data and storage models)
            errors.dart     (Error models)
            storage.dart    (Storage models)
        backend.dart        (Backend API)
        basis_backend.dart  (BASIS HTML parser logic)
        basis.dart          (BASIS server communication logic) 
    
```


