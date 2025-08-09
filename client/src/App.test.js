import { render, screen, waitFor } from '@testing-library/react';
import App from './App';

// Mock fetch for testing
global.fetch = jest.fn();

beforeEach(() => {
  fetch.mockClear();
});

test('renders ZForums header', async () => {
  // Mock the API response
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => [],
  });

  render(<App />);
  
  // Wait for loading to finish and check for ZForums title
  await waitFor(() => {
    const titleElement = screen.getByText(/🏛️ ZForums/i);
    expect(titleElement).toBeInTheDocument();
  });
});

test('renders new post button', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => [],
  });

  render(<App />);
  
  await waitFor(() => {
    const newPostButton = screen.getByText(/\+ New Post/i);
    expect(newPostButton).toBeInTheDocument();
  });
});

test('shows loading state initially', () => {
  fetch.mockImplementation(() => new Promise(() => {})); // Never resolves
  
  render(<App />);
  const loadingElement = screen.getByText(/Loading.../i);
  expect(loadingElement).toBeInTheDocument();
});
