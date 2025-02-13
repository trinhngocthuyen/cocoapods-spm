[< Documentation](README.md)

# Declaring Packages in Podfile

### The `spm_pkg` Syntax

Declaring a package (in Podfile) can be done with the `spm_pkg` method.
```rb
spm_pkg "Orcam", :git => "https://github.com/trinhngocthuyen/orcam.git", :tag => "0.0.1"
```

You may see an SPM package as another form of pod. In this sense, the `spm_pkg` syntax is similar to the `pod` syntax. Most of the supported options (in the `pod` method) are also available in the `spm_pkg`. As follows are some common usages.

| Syntax | Description |
| ------ | ----------- |
| `spm_pkg "A", :url => "...", :version => "0.0.1"` | |
| `spm_pkg "A", :git => "...", :tag => "0.0.1"` | `:git` is an alias for `:url`.<br>`:tag` is an alias for `:version` |
| `spm_pkg "A", :git => "...", :branch => "main"` | Use a branch |
| `spm_pkg "A", :git => "...", :commit => "abc1234"` | Use a specific commit |

> [!NOTE]
> Unlike a pod (whose source is implicitly inferred from specs repos), an SPM package does not have such sources by default.\
> While you can simply specify `pod "A", "1.0.0"`, you cannot use such a style (`spm_pkg "A", "1.0.0"`) because the plugin cannot resolve the package source (which url/git repo to fetch).\
> Therefore, the `:git`/`:url`/`:path` is always needed to resolve a package's source.

### SPM-specific Requirement

| Syntax | Description |
| ------ | ----------- |
| `spm_pkg "A", :git => "...", :up_to_next_major_version => "2.0.0"` | Up to next major version |
| `spm_pkg "A", :git => "...", :up_to_next_minor_version => "2.0.0"` | Up to next minor version |
| `spm_pkg "A", :git => "...", :version_range => ["2.0.0", "3.0.0"]` | Version range 2.0.0 -> 3.0.0 |

Moreover, you can also use the `:requirement` option to specify the package requirement yourself. The above options can be translated to the `:requirement` option as follows.

| Requirement | Shortcut for |
| ----------- | ------------ |
| `:version => "2.0.0"` | `:requirement => { :kind => "exactVersion", :version => "2.0.0" }` |
| `:up_to_next_major_version => "2.0.0"` | `:requirement => { :kind => "upToNextMajorVersion", :minimumVersion => "2.0.0" }` |
| `:up_to_next_minor_version => "2.0.0"` | `:requirement => { :kind => "upToNextMinorVersion", :minimumVersion => "2.0.0" }` |
| `:version_range => ["2.0.0", "3.0.0"]` | `:requirement => { :kind => "versionRange", :minimumVersion => "2.0.0", :maximumVersion => "3.0.0" }` |
