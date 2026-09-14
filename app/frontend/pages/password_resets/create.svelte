<script>
  const {
    current_user
  } = $props()
</script>

<main>
  <section>
    <h2>
      Check your email
    </h2>
    <p>
      {#if current_user}
        We've sent you a link to reset your password. It should arrive shortly.
        Make sure to check your spam folder.
      {:else}
        If an account exists for that email, you should receive a link to reset your password shortly.
        Make sure to check your spam folder.
      {/if}
    </p>
  </section>
  {#if !current_user}
  <section class="text-center text-gray">
    <p>
      <a href="/session/new" data-replace>Back to login</a>
    </p>
  </section>
  {/if}
</main>
