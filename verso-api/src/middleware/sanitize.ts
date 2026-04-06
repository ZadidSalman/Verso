import sanitizeHtml from 'sanitize-html';
import { Request, Response, NextFunction } from 'express';

// ─────────────────────────────────────────────────────────────────────────────
// SANITIZE CONFIGURATION
// ─────────────────────────────────────────────────────────────────────────────

const defaultOptions: sanitizeHtml.IOptions = {
  allowedTags: [],
  allowedAttributes: {},
  allowedClasses: {},
  disallowedTagsMode: 'discard',
  textFilter: (text: string) => {
    return text
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&nbsp;/g, ' ');
  },
};

const poemContentOptions: sanitizeHtml.IOptions = {
  allowedTags: ['br', 'p', 'em', 'strong', 'i', 'b'],
  allowedAttributes: {},
  allowedClasses: {},
  disallowedTagsMode: 'discard',
  textFilter: defaultOptions.textFilter,
};

// ─────────────────────────────────────────────────────────────────────────────
// SANITIZE FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

export function sanitizeText(input: string): string {
  return sanitizeHtml(input, defaultOptions).trim();
}

export function sanitizePoemContent(input: string): string {
  return sanitizeHtml(input, poemContentOptions).trim();
}

export function sanitizeObject(
  obj: Record<string, unknown>,
  fields: string[],
  options?: sanitizeHtml.IOptions
): Record<string, unknown> {
  const sanitized = { ...obj };
  const opts = options ?? defaultOptions;

  for (const field of fields) {
    const value = sanitized[field];
    if (typeof value === 'string') {
      sanitized[field] = sanitizeHtml(value, opts).trim();
    }
  }

  return sanitized;
}

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────

export function sanitizeBody(fields: string[], options?: sanitizeHtml.IOptions) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (req.body && typeof req.body === 'object') {
      req.body = sanitizeObject(req.body, fields, options);
    }
    next();
  };
}

export function sanitizeAllTextFields(
  _req: Request,
  _res: Response,
  next: NextFunction
): void {
  const req = _req as Request;
  if (req.body && typeof req.body === 'object') {
    const textFields = Object.keys(req.body).filter(
      (key) => typeof req.body[key] === 'string'
    );
    req.body = sanitizeObject(req.body, textFields);
  }
  next();
}
