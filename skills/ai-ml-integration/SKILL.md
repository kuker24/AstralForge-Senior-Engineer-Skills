---
name: ai-ml-integration
description: Integrate AI/ML capabilities into applications. Use when implementing OpenAI API, embeddings, RAG, tool calling, or building AI-powered features.
---

# AI/ML Integration

## When to Use

- Integrating OpenAI/Claude API
- Implementing embeddings and vector search
- Building RAG (Retrieval Augmented Generation)
- Adding tool calling capabilities
- Implementing prompt engineering

## Input

- AI requirements
- Data for embeddings/training
- Prompt templates

## Output

- AI API integration
- Embedding pipeline
- Vector database setup
- Evaluation framework

## Checklist

1. **API Integration**
   - Set up API client
   - Implement error handling
   - Add retry logic
   - Monitor usage/costs

2. **Embeddings**
   - Generate embeddings
   - Store in vector database
   - Implement similarity search
   - Update embeddings

3. **RAG Implementation**
   - Document loading
   - Chunking strategy
   - Retrieval logic
   - Context injection

4. **Evaluation**
   - Define success metrics
   - Create test dataset
   - Implement evaluation
   - Monitor performance

## Best Practices

- Use streaming for responses
- Implement proper error handling
- Add fallback for AI failures
- Monitor token usage
- Cache common responses
- Version prompts
- Evaluate regularly

## Anti-Patterns

❌ No error handling
❌ Ignoring token limits
❌ No fallback strategy
❌ Hardcoded prompts
❌ No evaluation
❌ Ignoring costs

## Validation

- API calls succeed
- Responses are relevant
- Error handling works
- Costs are acceptable
- Latency is acceptable

## Examples

### Example 1: OpenAI Integration
```typescript
// lib/ai/openai.ts
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export async function* streamChat(
  messages: ChatMessage[],
  model: string = 'gpt-4'
) {
  const stream = await openai.chat.completions.create({
    model,
    messages,
    stream: true,
    temperature: 0.7,
    max_tokens: 1000,
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) {
      yield content;
    }
  }
}

export async function getEmbedding(text: string): Promise<number[]> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: text,
  });
  
  return response.data[0].embedding;
}
```

### Example 2: RAG Implementation
```typescript
// lib/ai/rag.ts
import { Pinecone } from '@pinecone-database/pinecone';
import { getEmbedding } from './openai';

const pinecone = new Pinecone({
  apiKey: process.env.PINECONE_API_KEY!,
});

const index = pinecone.Index(process.env.PINECONE_INDEX!);

export async function indexDocument(doc: {
  id: string;
  content: string;
  metadata: any;
}) {
  // Chunk document
  const chunks = chunkText(doc.content, 500, 50);
  
  // Generate embeddings
  const embeddings = await Promise.all(
    chunks.map(chunk => getEmbedding(chunk))
  );
  
  // Store in Pinecone
  const vectors = chunks.map((chunk, i) => ({
    id: `${doc.id}-${i}`,
    values: embeddings[i],
    metadata: {
      ...doc.metadata,
      chunk,
      docId: doc.id,
    },
  }));
  
  await index.upsert(vectors);
}

export async function search(
  query: string,
  topK: number = 5
): Promise<Array<{ content: string; score: number }>> {
  const queryEmbedding = await getEmbedding(query);
  
  const results = await index.query({
    vector: queryEmbedding,
    topK,
    includeMetadata: true,
  });
  
  return results.matches.map(match => ({
    content: match.metadata?.chunk as string,
    score: match.score || 0,
  }));
}

export async function ragQuery(question: string): Promise<string> {
  // Retrieve relevant context
  const context = await search(question, 3);
  
  // Build prompt with context
  const messages: ChatMessage[] = [
    {
      role: 'system',
      content: `Answer the question based on the following context:\n\n${context.map(c => c.content).join('\n\n')}`,
    },
    { role: 'user', content: question },
  ];
  
  // Generate response
  let response = '';
  for await (const chunk of streamChat(messages)) {
    response += chunk;
  }
  
  return response;
}

function chunkText(text: string, chunkSize: number, overlap: number): string[] {
  const chunks: string[] = [];
  let start = 0;
  
  while (start < text.length) {
    const end = Math.min(start + chunkSize, text.length);
    chunks.push(text.slice(start, end));
    start = end - overlap;
  }
  
  return chunks;
}
```

### Example 3: Tool Calling
```typescript
// lib/ai/tools.ts
import OpenAI from 'openai';

const openai = new OpenAI();

const tools: OpenAI.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'get_weather',
      description: 'Get current weather for a location',
      parameters: {
        type: 'object',
        properties: {
          location: { type: 'string', description: 'City name' },
        },
        required: ['location'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'search_products',
      description: 'Search for products',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Search query' },
          limit: { type: 'number', description: 'Max results' },
        },
        required: ['query'],
      },
    },
  },
];

export async function chatWithTools(messages: OpenAI.ChatCompletionMessageParam[]) {
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages,
    tools,
    tool_choice: 'auto',
  });

  const message = response.choices[0].message;

  if (message.tool_calls) {
    for (const toolCall of message.tool_calls) {
      const result = await executeTool(toolCall);
      messages.push(message, {
        role: 'tool',
        tool_call_id: toolCall.id,
        content: JSON.stringify(result),
      });
    }

    return chatWithTools(messages);
  }

  return message.content;
}

async function executeTool(toolCall: OpenAI.ChatCompletionMessageToolCall) {
  const args = JSON.parse(toolCall.function.arguments);
  
  switch (toolCall.function.name) {
    case 'get_weather':
      return await getWeather(args.location);
    case 'search_products':
      return await searchProducts(args.query, args.limit);
    default:
      throw new Error(`Unknown tool: ${toolCall.function.name}`);
  }
}
```

### Example 4: Evaluation Framework
```typescript
// lib/ai/eval.ts
interface EvalCase {
  input: string;
  expected: string;
  actual?: string;
  score?: number;
}

export async function runEvaluation(
  evalCases: EvalCase[],
  handler: (input: string) => Promise<string>
): Promise<{ accuracy: number; results: EvalCase[] }> {
  const results: EvalCase[] = [];
  
  for (const testCase of evalCases) {
    const actual = await handler(testInput);
    const score = calculateSimilarity(testCase.expected, actual);
    
    results.push({
      ...testCase,
      actual,
      score,
    });
  }
  
  const accuracy = results.reduce((sum, r) => sum + (r.score || 0), 0) / results.length;
  
  return { accuracy, results };
}

function calculateSimilarity(expected: string, actual: string): number {
  // Simple word overlap for demo
  const expectedWords = new Set(expected.toLowerCase().split(/\s+/));
  const actualWords = new Set(actual.toLowerCase().split(/\s+/));
  
  const intersection = new Set([...expectedWords].filter(w => actualWords.has(w)));
  
  return intersection.size / expectedWords.size;
}
```

## Vector Database Options

| Database | Type | Best For |
|----------|------|----------|
| Pinecone | Cloud | Production |
| Weaviate | Self-hosted/Cloud | Flexibility |
| Qdrant | Self-hosted/Cloud | Performance |
| Chroma | Local/Cloud | Development |
| pgvector | PostgreSQL extension | Existing PostgreSQL |

## Output Structure

```
├── lib/
│   ├── ai/
│   │   ├── openai.ts        # OpenAI client
│   │   ├── rag.ts           # RAG implementation
│   │   ├── tools.ts         # Tool calling
│   │   ├── embeddings.ts    # Embedding utilities
│   │   └── eval.ts          # Evaluation
│   └── vector/
│       ├── pinecone.ts      # Vector DB client
│       └── search.ts        # Search utilities
├── prompts/
│   ├── system.md            # System prompts
│   └── templates/           # Prompt templates
├── data/
│   └── eval-cases.json      # Evaluation dataset
└── scripts/
    └── index-docs.ts        # Document indexing
```
