<script>
  import { Form } from 'inertiax-svelte'
  import Input from '~/components/Input.svelte'

  const { current_user } = $props()
</script>

<main>
  <section>
    <h3>
      Reset your password
    </h3>
    {#if current_user}
      <p>
        We'll send a link to reset your password to your current email address.
      </p>
    {:else}
      <p>
        Enter your email address and we'll send you a link to reset your password.
      </p>
    {/if}
    <Form action="/password_resets" method="post">
      {#snippet children({ errors })}
        {#if !current_user}
          <Input name="email" label="Email" type="email" {errors} />
        {/if}
        <button class="btn primary w-full mt-4" type="submit">
          Send reset link
        </button>
      {/snippet}
    </Form>
  </section>
  {#if !current_user}
    <section class="text-center text-gray">
      <p>
        <a href="/session/new" data-replace>Back to login</a>
      </p>
    </section>
  {/if}
</main>
