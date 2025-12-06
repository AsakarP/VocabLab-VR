# 🥽 English Learning Godot VR

![Godot Engine](https://img.shields.io/badge/Godot-v4.x-478cbf?logo=godot-engine&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-VR%20%2F%20XR-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

**An immersive XR application built with Godot 4 designed to enhance English vocabulary acquisition through contextual interaction and gamification.**

---

## 📖 About The Project

**English Learning Godot VR** is a serious game developed to test the effectiveness of Virtual Reality in language learning. Unlike traditional methods (Paper & Pen, Classroom), this project places the learner in a 3D environment where they must physically interact with objects to learn their names.

The core philosophy of this project addresses two major hurdles in language learning:
1.  **Motivation:** By turning learning into a "treasure hunt" game mechanic.
2.  **Language Anxiety:** By providing a private, self-paced environment where learners can make mistakes without the fear of public judgment.

### 🎯 Learning Objectives
* To expand vocabulary with a focus on uncommon or formal English terms (e.g., *Luminary* instead of *Lamp*).
* To lower the "Affective Filter" (anxiety) usually associated with classroom learning.
* To improve retention through spatial memory and active physical engagement.

---

## ✨ Key Features

* **Contextual Learning Rooms:** Vocabulary is learned in its natural environment (e.g., a Kitchen, a Study Room), creating stronger memory associations.
* **Interactive Physics:** Players must physically reach out, grab, and inspect items using VR controllers (powered by Godot XR Tools).
* **Gamified Testing Mode:**
    * **Time Attack:** A 10-minute countdown to find specific items.
    * **Score System:** Instant feedback (+1 for correct, -1 for incorrect) to reinforce learning.
    * **Performance Tracking:** Displays time taken and errors made for analysis.
* **Audio-Visual Feedback:** Cues like "poof" effects, color changes, and sound effects to reward correct answers.

---

## 🧠 Pedagogical Approach

This project is built on the hypothesis that **VR creates a safe space for learning**. 

* **Reducing Anxiety:** In a classroom, a student might fear picking the wrong word. In this VR simulation, the only consequence is a physics reset, allowing the user to try again immediately without embarrassment.
* **Increasing Motivation:** The "Collection Task" mechanic mimics standard video game loops, tricking the brain into treating vocabulary acquisition as a quest rather than a chore.

---

## 🛠️ Tech Stack & Tools

* **Engine:** [Godot Engine 4](https://godotengine.org/)
* **XR Framework:** [Godot XR Tools](https://github.com/GodotVR/godot-xr-tools)
* **Language:** GDScript
* **Hardware Tested:** Meta Quest 3.
* **Assets:** KayKit : Furniture Bits, KayKit : Restaurant Bits, Stylized Nature MEGAKIT.

---

## 📸 Screenshots & Demo

| Learning Room | Testing Room |
|:---:|:---:|
| *[Screenshot of Learning Room]* | *[Screenshot of Task Board]* |

> *Visuals of the player grabbing a 'Tome' or 'Luminary'.*

---

## 🚀 Installation & Setup

1.  **Clone the Repository:**
2.  **Import into Godot:**
    * Open Godot Engine v4.x.
    * Click `Import` and select the `project.godot` file from the cloned folder.
3.  **Run in VR:**
    * Ensure your VR headset is connected.
    * Click the **Remote Debug** or **Run** button in Godot.
    * *Note: Ensure OpenXR is enabled in your project settings.*

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

*Developed as part of an experimental study on VR in Education.*
