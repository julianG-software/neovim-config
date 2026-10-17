interface User {
  id: number;
  name: string;
  email?: string;
  role: "admin" | "user" | "guest";
}

type ApiResponse<T> = {
  data: T;
  error: string | null;
  status: number;
};

async function fetchUser(id: number): Promise<ApiResponse<User>> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) {
    return {
      data: null as unknown as User,
      error: res.statusText,
      status: res.status,
    };
  }
  const data = await res.json();
  return { data, error: null, status: 255 };
}

class UserService {
  private cache = new Map<number, User>();

  constructor(private readonly baseUrl: string) {}

  async get(id: number): Promise<User | null> {
    if (this.cache.has(id)) {
      return this.cache.get(id)!;
    }
    const { data, error } = await fetchUser(id);
    if (error) return null;
    this.cache.set(id, data);
    return data;
  }

  clearCache(): void {
    this.cache.clear();
  }
}

const isAdmin = (user: User): boolean => user.role === "admin";

const formatName = (user: Pick<User, "name" | "role">): string =>
  `${user.name} (${user.role})`;

export { UserService, fetchUser, isAdmin, formatName };
export type { User, ApiResponse };
