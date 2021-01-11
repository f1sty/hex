defmodule Hex.Crypto do
  @moduledoc false

  alias Hex.Crypto.Encryption

  def encrypt(plain_text, password, tag \\ "") do
    # TODO: Change :enc to "A256GCM" once support for OTP 17 is dropped.
    protected = %{
      alg: "PBES2-HS512",
      enc: "A256CBC-HS512",
      p2c: Hex.State.fetch!(:pbkdf2_iters),
      p2s: :crypto.strong_rand_bytes(16)
    }

    Encryption.encrypt({tag, plain_text}, protected, password: password)
  end

  def decrypt(cipher_text, password, tag \\ "") do
    Encryption.decrypt({tag, cipher_text}, password: password)
  end

  def hmac(type, key, data) do
    :crypto.mac(:hmac, type, key, data)
  end

  def base64url_encode(binary) do
    try do
      Base.url_encode64(binary, padding: false)
    catch
      _, _ ->
        binary
        |> Base.encode64()
        |> urlsafe_encode64(<<>>)
    end
  end

  def base64url_decode(binary) do
    try do
      Base.url_decode64(binary, padding: false)
    catch
      _, _ ->
        try do
          binary = urlsafe_decode64(binary, <<>>)

          binary =
            case rem(byte_size(binary), 4) do
              2 -> binary <> "=="
              3 -> binary <> "="
              _ -> binary
            end

          Base.decode64(binary)
        catch
          _, _ ->
            :error
        end
    end
  end

  defp urlsafe_encode64(<<?+, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, ?->>)
  end

  defp urlsafe_encode64(<<?/, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, ?_>>)
  end

  defp urlsafe_encode64(<<?=, rest::binary>>, acc) do
    urlsafe_encode64(rest, acc)
  end

  defp urlsafe_encode64(<<c, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, c>>)
  end

  defp urlsafe_encode64(<<>>, acc) do
    acc
  end

  defp urlsafe_decode64(<<?-, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, ?+>>)
  end

  defp urlsafe_decode64(<<?_, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, ?/>>)
  end

  defp urlsafe_decode64(<<c, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, c>>)
  end

  defp urlsafe_decode64(<<>>, acc) do
    acc
  end
end
