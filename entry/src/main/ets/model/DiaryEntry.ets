
export class DiaryEntry {
  id: number | null;
  content: string;
  mood: string; // Emoji
  intensity: number; // 1-5
  tags: string; // JSON string of string[]
  images: string; // JSON string of string[]
  createdAt: number; // Timestamp
  updatedAt: number; // Timestamp

  constructor(
    content: string,
    mood: string,
    intensity: number,
    tags: string[] = [],
    images: string[] = [],
    id: number | null = null,
    createdAt: number = new Date().getTime(),
    updatedAt: number = new Date().getTime()
  ) {
    this.id = id;
    this.content = content;
    this.mood = mood;
    this.intensity = intensity;
    this.tags = JSON.stringify(tags);
    this.images = JSON.stringify(images);
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }
}

export class StardustLog {
  id: number | null;
  amount: number;
  reason: string;
  createdAt: number;

  constructor(amount: number, reason: string, id: number | null = null, createdAt: number = new Date().getTime()) {
    this.id = id;
    this.amount = amount;
    this.reason = reason;
    this.createdAt = createdAt;
  }
}
