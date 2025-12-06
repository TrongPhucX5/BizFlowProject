# BizFlow - Platform to Support Digital Transformation for Household Businesses

**Vietnamese:** Nền tảng hỗ trợ chuyển đổi số cho hộ kinh doanh.

## 📖 1. Context & Problem Statement

In Vietnam, household businesses play a critical role in the local economy, especially in traditional sectors like building materials and hardware retail. Most fall under Group 1 or Group 2 (Ministry of Finance's Decision 3389/QĐ-BTC - 2025).

**The Pain Points:**

- **Manual Workflows:** Relying on handwritten notebooks or simple Excel files for sales, inventory, and debt tracking.
- **Unique Operations:** Commercial POS systems fail to address multi-channel orders (Phone/Zalo), long-term customer debt, and low digital literacy.
- **Hardware Constraints:** Lack of budget for computers, barcode scanners, or receipt printers. Most operate with a single smartphone.
- **Compliance Issues:** Difficulty in generating reports compliant with **Circular 88/2021/TT-BTC**.

## 🚀 2. Our Solution: BizFlow

BizFlow is a specialized platform designed for traditional stores. It integrates an **AI-powered assistant** capable of understanding natural language (text or voice) to automate order creation and bookkeeping.

**Key Value Propositions:**

- **AI Automation:** Convert natural language (e.g., "get 5 cement bags for Mr. Ba") into draft orders.
- **Auto-Bookkeeping:** Automatically populates financial reports required by Circular 88/2021/TT-BTC.
- **Mobile-First:** Fully functional on smartphones without needing expensive POS hardware.

## ✨ 3. Key Features

### 🧑‍💼 Employee App

- **Smart Order Creation:** Create orders via UI or Voice/Chat command.
- **Debt Recording:** Record debt directly during order creation.
- **Printing:** Generate and print sales orders using pre-designed templates.
- **Real-time Notifications:** Receive alerts when AI generates a draft order from a message.

### 🏪 Owner Dashboard

- **Everything in Employee App**, plus:
- **Catalog Management:** Manage products, prices, and multiple units of measure.
- **Inventory Management:** Real-time stock tracking and import history.
- **Customer & Debt Management:** Track purchase history and outstanding debts.
- **Analytics:** Interactive dashboards for revenue, best-sellers, and debt.
- **Staff Management:** Create accounts and manage permissions.

### ⚙️ System & AI

- **NLP Engine:** Converts natural language voice/text into structured draft orders.
- **Automated Accounting:** Generates detailed revenue ledgers and business operation reports automatically.

### 🛡️ Admin Portal

- Manage household business accounts (Owners).
- Configure subscription pricing.
- Update global financial report templates (Circular 88/2021/TT-BTC).

## 🛠️ 4. Tech Stack

### Server-side

- **Architecture:** Clean Architecture
- **Database:** MySQL, PostgreSQL
- **Caching:** Redis

### AI & Machine Learning

- **Language:** Python
- **RAG:** ChromaDB, `text-embedding-3-small`
- **LLM:** OpenAI / Gemini
- **Speech-to-Text:** Google Speech-to-Text / Whisper

### Client-side

- **Mobile Application:** Flutter (with Notifications)
- **Web Client:** NextJS, Tanstack Query, Shadcn UI, TailwindCSS

## 📂 5. Project Deliverables

This project applies standard software development processes and UML 2.0 modeling. The repository includes:

- Source code (Mobile & Web)
- User Requirement & SRS
- Architecture & Detailed Design Documents
- System Implementation & Testing Documents
- Installation Guide

## 🗓️ 6. Roadmap / Tasks

- [ ] **Task Package 1:** Deploy databases (MySQL and PostgreSQL).
- [ ] **Task Package 2:** Set up Clean Architecture backend.
- [ ] **Task Package 3:** Develop and deploy the Mobile Application (Flutter).
- [ ] **Task Package 4:** Develop and deploy the Web Application (NextJS).

---

_Note: This project is designed to comply with Vietnam's accounting standards for household businesses._
