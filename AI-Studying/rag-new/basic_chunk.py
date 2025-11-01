# Task 3: Install Chunking Dependencies

# Why do we need these tools?

# 🔧 LangChain: A powerful framework for building RAG applications

# Provides RecursiveCharacterTextSplitter for smart document chunking
# Handles different chunk sizes, overlaps, and separators
# Makes chunking configuration simple and flexible
# 🧠 spaCy: Advanced natural language processing library

# Provides SpacyTextSplitter for sentence-aware chunking
# Understands sentence boundaries and linguistic structure
# Breaks documents at natural language boundaries (not just characters)
# Installation Steps:

# Navigate to the project:
# cd /home/lab-user/rag-project

# Install chunking packages:
# uv pip install langchain spacy


#!/usr/bin/env python3
"""
Basic Document Chunking Demo
Using LangChain's RecursiveCharacterTextSplitter
"""

from langchain.text_splitter import RecursiveCharacterTextSplitter

print("✂️ Basic Document Chunking Demo")
print("=" * 50)

# Sample policy document
policy_document = """
TechCorp Remote Work Policy

Employees may work remotely up to 3 days per week with manager approval. 
Remote work days must be scheduled in advance and approved by your direct supervisor.
All remote work must comply with company security policies and use approved equipment.
Employees working remotely are expected to maintain regular communication with their team.
Performance expectations remain the same regardless of work location.

Remote work is not a substitute for childcare or eldercare responsibilities.
Employees must have a dedicated workspace free from distractions.
All company equipment must be returned if remote work arrangement is terminated.
"""

print("📄 Original Document:")
print(f"Length: {len(policy_document)} characters")
print(f"Content: {policy_document[:100]}...")
print()

# Create text splitter
print("🔧 Creating LangChain RecursiveCharacterTextSplitter...")
splitter = RecursiveCharacterTextSplitter(
    chunk_size=200,  # Maximum characters per chunk
    chunk_overlap=50,  # Overlap between chunks
    separators=["\n\n", "\n", " ", ""]  # Try these separators in order
)

# Split the document
print("✂️ Splitting document into chunks...")
chunks = splitter.split_text(policy_document)

print(f"✅ Created {len(chunks)} chunks")
print()

# Display chunks
print("📋 Chunk Details:")
for i, chunk in enumerate(chunks, 1):
    print(f"Chunk {i}:")
    print(f"  Length: {len(chunk)} characters")
    print(f"  Content: {chunk}")
    print(f"  Separator: {'-' * 30}")
    print()

print("💡 Basic Chunking Benefits:")
print("✅ Breaks large documents into manageable pieces")
print("✅ Each chunk focuses on specific information")
print("✅ Configurable chunk size and overlap")
print("✅ Handles multiple separators automatically")
print("✅ Simple and reliable")

# Create completion marker
with open("basic_chunking_complete.txt", "w") as f:
    f.write("Basic chunking demo completed successfully")

print("\n✅ Basic chunking demo completed!")

