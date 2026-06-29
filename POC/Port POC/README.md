# PortOps 360 — Intelligent Port Operations Analytics Platform

> **An enterprise-scale end-to-end data engineering project built on Azure and Microsoft Fabric that combines batch processing and real-time streaming to provide historical business intelligence and live operational visibility for modern container ports.**

---

# Project Overview

Modern container ports generate millions of operational events every day—from vessel arrivals and crane operations to truck movements and yard occupancy. However, historical reporting and real-time operational monitoring are often disconnected, making it difficult to optimize port efficiency.

**PortOps 360** solves this problem by building two complementary analytics platforms:

* **Historical Analytics Platform** – for strategic analysis, KPI reporting, trend analysis, and executive decision making.
* **Live Operations Command Center** – for real-time monitoring of ongoing port activities, congestion detection, and operational awareness.

The project demonstrates how to build an enterprise-grade data platform using **Azure** and **Microsoft Fabric**, covering both **batch** and **streaming** architectures.

---

# Objectives

* Build a complete Medallion Architecture using Microsoft Fabric
* Implement both Batch and Streaming data pipelines
* Design a normalized operational database (3NF)
* Build a dimensional warehouse (Star Schema)
* Create historical and real-time Power BI dashboards
* Demonstrate enterprise data engineering best practices

---

# Business Problem

Container terminals handle thousands of operational events every day:

* Vessel arrivals
* Crane operations
* Container movement
* Truck gate processing
* Yard occupancy
* Equipment maintenance

Without an integrated analytics platform, operations teams struggle to answer questions such as:

* Which berth is underutilized?
* Which cranes are experiencing downtime?
* Which yard blocks are nearing capacity?
* How long do vessels stay in port?
* What is the average container dwell time?
* Are trucks experiencing delays at the gates?
* What is happening in the port right now?

PortOps 360 addresses these challenges through batch analytics and real-time monitoring.

---

# Architecture

The solution is divided into two independent architectures.

## Historical Analytics

```text
Azure SQL Database
        │
        ▼
Azure Data Factory
        │
        ▼
Azure Data Lake Storage Gen2
        │
        ▼
Fabric Bronze Lakehouse
        │
        ▼
Fabric Silver Lakehouse
        │
        ▼
Fabric Gold Lakehouse
        │
        ▼
Fabric Warehouse
        │
        ▼
Power BI Historical Dashboard
```

---

## Live Operations

```text
Azure Function
        │
        ▼
Azure Event Hub
        │
        ▼
Fabric Eventstream
        │
        ▼
Bronze Streaming Tables
        │
        ▼
Silver Streaming Tables
        │
        ▼
Power BI Live Dashboard
```

---

# Technology Stack

## Azure

* Azure SQL Database
* Azure Data Factory
* Azure Data Lake Storage Gen2
* Azure Functions
* Azure Event Hub

---

## Microsoft Fabric

* Lakehouse
* Eventstream
* Pipelines
* Notebooks
* SQL Endpoint
* Semantic Models
* Power BI

---

## Languages

* Python
* SQL
* PySpark
* DAX

---

# Data Model

## Operational Database (3NF)

The operational system is modeled using Third Normal Form.

Main entities include:

* Vessel
* Shipping Line
* Berth
* Crane
* Yard Block
* Truck
* Gate
* Equipment
* Importer
* Container
* Vessel Call
* Maintenance
* Gate Transaction
* Crane Event

---

## Analytical Model (Star Schema)

### Dimensions

* Dim Date
* Dim Vessel
* Dim Shipping Line
* Dim Berth
* Dim Crane
* Dim Yard Block
* Dim Gate
* Dim Equipment
* Dim Truck
* Dim Importer

### Facts

* Fact Vessel Operations
* Fact Container Flow
* Fact Gate Performance
* Fact Crane Performance
* Fact Yard Utilization
* Fact Maintenance

---

# Historical Data Pipeline

## Step 1

Historical data is stored inside Azure SQL Database.

---

## Step 2

Azure Data Factory performs extraction.

---

## Step 3

Extracted data is stored in ADLS Gen2.

---

## Step 4

Fabric Lakehouse Shortcuts expose ADLS data to the Bronze Lakehouse.

---

## Step 5

Bronze notebooks ingest raw files into Delta tables.

---

## Step 6

Silver notebooks perform:

* Data cleansing
* Type conversion
* Validation
* Deduplication
* Data quality checks
* Standardization

---

## Step 7

Gold notebooks create business-ready fact and dimension tables.

---

## Step 8

Fabric Warehouse exposes the dimensional model.

---

## Step 9

Power BI connects using Direct Lake.

---

# Live Streaming Pipeline

Synthetic operational events are generated using Azure Functions.

Event Types:

* Gate Transactions
* Crane Operations
* Yard Occupancy

---

The events flow through:

```text
Azure Function
        │
        ▼
Azure Event Hub
        │
        ▼
Fabric Eventstream
        │
        ▼
Bronze Streaming Table
```

Silver notebooks separate and enrich streaming events into:

* silver_gate_transaction
* silver_crane_event
* silver_yard_snapshot

Power BI consumes these tables directly for low-latency operational dashboards.

---

# Medallion Architecture

## Bronze

Purpose:

Raw immutable data.

Contains:

* Historical extracts
* Streaming events

---

## Silver

Purpose:

Business-ready operational data.

Processes include:

* Cleaning
* Standardization
* Deduplication
* Data enrichment
* Business validation

---

## Gold

Purpose:

Analytics-ready dimensional model.

Includes:

* Fact tables
* Dimension tables
* Business calculations
* Aggregated KPIs

---

# Historical Dashboard

## Executive Overview

KPIs

* Total Containers
* Vessel Calls
* Crane Productivity
* Yard Utilization
* Revenue Metrics

---

## Vessel Operations

* Turnaround Time
* Waiting Time
* Containers Loaded
* Containers Unloaded

---

## Yard Analytics

* Yard Utilization
* Capacity Trends
* Container Dwell Time

---

# Live Dashboard

## Command Center

Real-time KPIs

* Active Cranes
* Active Trucks
* Current Yard Utilization
* Active Vessel Calls

---

## Yard Monitoring

* Occupancy
* Congestion
* Capacity Alerts

---

## Gate Monitoring

* Truck Queue
* Gate Activity
* Throughput


---

# Data Engineering Concepts Demonstrated

* Medallion Architecture
* Batch Processing
* Streaming Data Processing
* Delta Lake
* Lakehouse Architecture
* Data Warehouse
* Star Schema
* 3NF Database Design
* Pipeline Orchestration
* Event-Driven Architecture
* Real-Time Analytics
* Direct Lake
* Semantic Modeling

---

# Skills Demonstrated

* Azure Data Engineering
* Microsoft Fabric
* PySpark
* SQL Development
* Data Warehouse Design
* Real-Time Streaming
* Event-Driven Systems
* Power BI
* Dimensional Modeling
* Data Modeling
* Azure Functions
* Azure Event Hub
* Azure Data Factory
* Delta Lake
* Medallion Architecture