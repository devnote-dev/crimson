module Crimson::ENV
  CRIMSON_LIBRARY = begin
    {% if flag?(:win32) %}
      Path[::ENV["APPDATA"]] / "crimson"
    {% else %}
      if data = ::ENV["XDG_DATA_HOME"]?
        Path[data] / "crimson"
      else
        Path.home / ".local" / "share" / "crimson"
      end
    {% end %}
  end

  CRYSTAL_CACHE = begin
    {% if flag?(:win32) %}
      Path[::ENV["LOCALAPPDATA"]] / "crystal"
    {% else %}
      Path.home / ".cache" / "crystal"
    {% end %}
  end

  CRYSTAL_LIBRARY = begin
    {% if flag?(:win32) %}
      Path[::ENV["LOCALAPPDATA"]] / "Programs" / "Crystal"
    {% else %}
      Path["usr"] / "lib" / "crystal"
    {% end %}
  end

  def self.has_version?(version : String) : Bool
    Dir.exists? CRIMSON_LIBRARY / "crystal" / version
  end

  @@versions = [] of String

  # TODO: cache the response in file system
  def self.get_versions(force : Bool) : Array(String)
    return @@versions unless @@versions.empty?

    res = Crest.get "https://crystal-lang.org/api/versions.json"
    data = JSON.parse res.body

    @@versions = data["versions"].as_a.map &.["name"].as_s
  end
end
