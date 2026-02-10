<script>
  // 반응성 변수
  let count = 0;
  let name = 'World';

  // 함수
  function handleClick() {
    count += 1;
  }
</script>

<main>
  <h1>Hello {name}!</h1>

  <div class="card">
    <button on:click={handleClick}>
      Count is {count}
    </button>
  </div>
</main>

<style>
  main {
    text-align: center;
    padding: 2rem;
    max-width: 800px;
    margin: 0 auto;
  }

  h1 {
    color: #333;
    font-size: 2.5rem;
    margin-bottom: 2rem;
  }

  .card {
    padding: 2rem;
    background: #f5f5f5;
    border-radius: 8px;
  }

  button {
    padding: 0.5rem 1rem;
    font-size: 1rem;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
  }

  button:hover {
    background-color: #45a049;
  }
</style>
