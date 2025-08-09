import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showNewPostForm, setShowNewPostForm] = useState(false);
  const [newPost, setNewPost] = useState({
    title: '',
    content: '',
    author: ''
  });

  // Fetch posts from API
  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/posts');
      if (!response.ok) {
        throw new Error('Failed to fetch posts');
      }
      const data = await response.json();
      setPosts(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch('/api/posts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newPost),
      });

      if (!response.ok) {
        throw new Error('Failed to create post');
      }

      const createdPost = await response.json();
      setPosts([createdPost, ...posts]);
      setNewPost({ title: '', content: '', author: '' });
      setShowNewPostForm(false);
    } catch (err) {
      setError(err.message);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString();
  };

  if (loading) {
    return (
      <div className="app">
        <div className="loading">Loading...</div>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>🌙 ZForums Dark</h1>
        <p>A sleek dark forum for modern discussions</p>
      </header>

      <main className="main-content">
        <div className="actions">
          <button 
            className="new-post-btn"
            onClick={() => setShowNewPostForm(!showNewPostForm)}
          >
            {showNewPostForm ? 'Cancel' : '+ New Post'}
          </button>
        </div>

        {error && (
          <div className="error">
            Error: {error}
            <button onClick={() => setError(null)}>×</button>
          </div>
        )}

        {showNewPostForm && (
          <div className="new-post-form">
            <h3>Create New Post</h3>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="title">Title:</label>
                <input
                  type="text"
                  id="title"
                  value={newPost.title}
                  onChange={(e) => setNewPost({...newPost, title: e.target.value})}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="author">Author:</label>
                <input
                  type="text"
                  id="author"
                  value={newPost.author}
                  onChange={(e) => setNewPost({...newPost, author: e.target.value})}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="content">Content:</label>
                <textarea
                  id="content"
                  value={newPost.content}
                  onChange={(e) => setNewPost({...newPost, content: e.target.value})}
                  rows="5"
                  required
                />
              </div>
              <div className="form-actions">
                <button type="submit" className="submit-btn">Post</button>
                <button 
                  type="button" 
                  className="cancel-btn"
                  onClick={() => setShowNewPostForm(false)}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        <div className="posts-container">
          {posts.length === 0 ? (
            <div className="no-posts">
              <p>No posts yet. Be the first to start a discussion!</p>
            </div>
          ) : (
            posts.map((post) => (
              <div key={post.id} className="post-card">
                <div className="post-header">
                  <h2 className="post-title">{post.title}</h2>
                  <div className="post-meta">
                    <span className="post-author">by {post.author}</span>
                    <span className="post-date">{formatDate(post.created_at)}</span>
                  </div>
                </div>
                <div className="post-content">
                  <p>{post.content}</p>
                </div>
              </div>
            ))
          )}
        </div>
      </main>

      <footer className="app-footer">
        <p>ZForums - Powered by React & Node.js</p>
      </footer>
    </div>
  );
}

export default App;