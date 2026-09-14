<script>
  import { Form } from 'inertiax-svelte'
  import Input from '~/components/Input.svelte'

  const { verification } = $props()
</script>

<main>
  <section>
    <h2>
      Check your email
    </h2>
    <p>We've sent you a 5-digit confirmation code to <strong>{verification.email}</strong>. It might have gone into your spam folder. Please enter it below.</p>
    <Form action="/verifications/{verification.id}" method="patch">
      {#snippet children({ errors })}
        <Input name="code" label="Confirmation code" {errors} />
        <button class="btn primary w-full" type="submit">
          Continue
        </button>
      {/snippet}
    </Form>
    <p class="text-center text-sm text-gray mt-4">
      <a href="/users/new" data-replace>Use a different email</a>
    </p>
  </section>
</main>
