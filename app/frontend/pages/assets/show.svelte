<script>
  const {
    asset
  } = $props()
</script>

<main>
  <section>
    <nav>
      <a href="/">
        Assets
      </a>
      &RightAngleBracket; {asset.name}
    </nav>
  </section>
  <section>
    <h2>{asset.name}</h2>
    <p>{asset.description}</p>
    <p>Sign up to short</p>
  </section>
</main>