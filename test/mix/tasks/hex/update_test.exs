defmodule Mix.Tasks.Hex.UpdateTest do
  use HexTest.Case
  @moduletag :integration

  test "fetch registry" do
    in_tmp fn _ ->
      System.put_env("MIX_HOME", System.cwd!)

      File.mkdir_p!("tmp")
      HexWeb.RegistryBuilder.sync_rebuild

      refute File.exists?(Hex.Registry.path)

      Mix.Tasks.Hex.Update.run([])
      assert_received { :mix_shell, :info, ["Downloading registry..."] }
      assert_received { :mix_shell, :info, ["Registry update was successful!"] }
      assert File.exists?(Hex.Registry.path)

      Mix.Tasks.Hex.Update.run([])
      assert_received { :mix_shell, :info, ["Downloading registry..."] }
      assert_received { :mix_shell, :info, ["Registry update was successful!"] }
      assert File.exists?(Hex.Registry.path)
    end
  after
    System.delete_env("MIX_HOME")
  end
end
