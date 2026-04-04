/**
 * Safely extract a single string param from Express req.params
 * Express types params as string | string[], but with simple routes
 * they're always strings.
 */
export function param(params: Record<string, string | string[]>, name: string): string {
  const val = params[name];
  return Array.isArray(val) ? val[0] : val;
}
