<script>
  import { Form, page } from 'inertiax-svelte'
  import Input from '~/components/Input.svelte'
  import Socials from '~/pages/sessions/_socials.svelte'
  
  const { 
    close,
    verification
  } = $props()
  

  $effect(() => page.props.current_user && close(false))

</script>

<main>
  {#if verification}
    <section>
      <h3>Set password</h3>
      <p>Choose a password (minimum 8 characters) to finish setting up your account for <strong>{verification.email}</strong>.</p>
      <Form action="/user?verification_id={verification.id}" method="post">
        {#snippet children({ errors })}
          <Input type="password" name="password" label="Password" {errors} />
          <Input type="password" name="password_confirmation" label="Confirm password" {errors} />
          <button class="btn primary w-full" type="submit">
            Create Account
          </button>
        {/snippet}
      </Form>
    </section>
  {:else}
    <section>
      <h3>
        Create account
      </h3>
      <p class="text-gray mt-1">
        The next quality short will go live soon. Sign up to participate.
      </p>
      <Form action="/verifications" method="post">
        {#snippet children({ errors })}
          <Input name="email" label="Email" {errors} />
          <button class="btn primary w-full" type="submit">
            Sign up with email
          </button>
        {/snippet}
      </Form>
      <Socials flow="signup" text="Sign up with"/>
    </section>
    <section>
      <p class="text-center text-sm text-gray text-balance mt-4">
        By signing up, you agree to our
        <a href="/terms" target="_blank">Terms of Service</a>
        and
        <a href="/privacy" target="_blank">Privacy Policy</a>.
      </p>
    </section>
  {/if}
  <section class="text-center text-gray">
    <p>
      Already have an account?
      <a href="/session/new" data-replace>Log in</a>
    </p>
  </section>
</main>


