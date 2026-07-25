export class DomainError extends Error {
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export class UnauthorizedError extends DomainError {
  constructor(message = 'Unauthorized') {
    super(message);
  }
}

export class ForbiddenError extends DomainError {
  constructor(message = 'Forbidden') {
    super(message);
  }
}

export class NotFoundError extends DomainError {
  constructor(message = 'Not Found') {
    super(message);
  }
}

export class ValidationError extends DomainError {
  constructor(message = 'Validation Error') {
    super(message);
  }
}
