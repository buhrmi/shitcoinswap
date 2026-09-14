<script>
  import { Form } from 'inertiax-svelte'
  import Input from '~/components/Input.svelte'

  const { token } = $props()
</script>

<main>
  <section>
    <h3>
      Choose a new password
    </h3>
    <Form action="/password_resets/{token}" method="delete">
      {#snippet children({ errors })}
        <Input name="password" label="New password" type="password" {errors} />
        <Input name="password_confirmation" label="Confirm password" type="password" {errors} />
        <button class="btn primary w-full" type="submit">
          Reset password
        </button>
      {/snippet}
    </Form>
  </section>
</main>
