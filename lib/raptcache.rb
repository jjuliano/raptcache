  # = raptcache - A apt-cache gem for Ruby
  #
  # Homepage::  http://github.com/jjuliano/raptcache
  # Author::    Joel Bryan Juliano
  # Copyright:: (cc) 2011 Joel Bryan Juliano
  # License::   MIT
  #
  # class Raptcache::Package.new( array, str, array)

  require 'tempfile'

  class Raptcache
    #
    # All accessors are boolean unless otherwise noted.
    #

    #
    # Select the file to store the package cache.
    # The package cache is the primary cache used by all operations.
    # Configuration Item: Dir::Cache::pkgcache.
    #
    attr_accessor :pkg_cache

    #
    # Select the file to store the source cache. The source is used only
    # by gencaches and it stores a parsed version of the package information
    # from remote sources. When building the package cache the source
    # cache is used to avoid reparsing all of the package files.
    # Configuration Item: Dir::Cache::srcpkgcache.
    #
    attr_accessor :src_cache

    #
    # Quiet; produces output suitable for logging, omitting progress indicators.
    # You can also use 'quiet=#' to set the quietness level, overriding the
    # configuration file.
    # Configuration Item: quiet.
    #
    attr_accessor :quiet

    #
    # Print only important dependencies; for use with unmet and depends.
    # Causes only Depends and Pre-Depends relations to be printed.
    # Configuration Item: APT::Cache::Important.
    #
    attr_accessor :important

    #
    # Per default the depends and rdepends print all dependencies.
    # This can be twicked with these flags which will omit the specified
    # dependency type.
    # Configuration Item: APT::Cache::ShowDependencyType e.g.
    #       APT::Cache::ShowRecommends.
    #

    #
    # Omit the pre dependencies for depends and rdepends.
    #
    attr_accessor :no_pre_depends

    #
    # Omit all dependencies for depends and rdepends.
    #
    attr_accessor :no_depends

    #
    # Omit the recommended dependencies for depends and rdepends.
    #
    attr_accessor :no_recommends

    #
    # Omit the suggested dependencies for depends and rdepends.
    #
    attr_accessor :no_suggests

    #
    # Omit the conflicting dependencies for depends and rdepends.
    #
    attr_accessor :no_conflicts

    #
    # Omit the breaking dependencies for depends and rdepends.
    #
    attr_accessor :no_breaks

    #
    # Omit the replaces dependencies for depends and rdepends.
    #
    attr_accessor :no_replaces

    #
    # Omit the enhances dependencies for depends and rdepends.
    #
    attr_accessor :no_enhances

    #
    # Print full package records when searching.
    # Configuration Item: APT::Cache::ShowFull.
    #
    attr_accessor :full

    #
    # Print full records for all available versions. This is the default;
    # to turn it off, use 'no_all_versions'. If 'no_all_versions' is specified,
    # only the candidate version will displayed (the one which would be
    # selected for installation). This option is only applicable to the
    # show command.
    # Configuration Item: APT::Cache::AllVersions.
    #
    attr_accessor :all_versions

    #
    # Perform automatic package cache regeneration, rather than use the cache
    # as it is. This is the default; to turn it off, use 'no_generate'.
    # Configuration Item: APT::Cache::Generate.
    #
    attr_accessor :generate

    #
    # Only search on the package names, not the long descriptions.
    # Configuration Item: APT::Cache::NamesOnly.
    #
    attr_accessor :names_only

    #
    # Make pkgnames print all names, including virtual packages and missing
    # dependencies.
    # Configuration Item: APT::Cache::AllNames.
    #
    attr_accessor :all_names

    #
    # Make depends and rdepends recursive so that all packages mentioned
    # are printed once.
    # Configuration Item: APT::Cache::RecurseDepends.
    #
    attr_accessor :recurse

    #
    # Limit the output of depends and rdepends to packages which are
    # currently installed.
    # Configuration Item: APT::Cache::Installed.
    #
    attr_accessor :installed

    #
    # Show the program version.
    #
    attr_accessor :version

    #
    # Configuration File; Specify a configuration file to use.
    # The program will read the default configuration file and then this
    # configuration file. If configuration settings need to be set before
    # the default configuration files are parsed specify a file with the
    # APT_CONFIG environment variable. See apt.conf for syntax information.
    #
    attr_accessor :config_file

    #
    # Set a Configuration Option; This will set an arbitrary
    # configuration option.
    # The syntax is option = "Foo::Bar=bar"
    #
    attr_accessor :option

    #
    # Returns a new Raptcache Object
    #
    def initialize()
    end

    #
    # add adds the named package index files to the package cache.
    # This is for debugging only.
    #
    def add(files)

      tmp = Tempfile.new('tmp')
      files.collect! { |i| i + " " }
      command = option_string() + "add " + files.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    #	gencaches performs the same operation as apt-get check.
    # It builds the source and package caches from the sources in
    # sources.list and from /var/lib/dpkg/status.
    # (require's root permission)
    #
    def gencaches

      command = option_string() + "gencaches "
      success = system(command)
      return success

    end

    # showpkg displays information about the packages listed on the
    # command line. Remaining arguments are package names.
    # The available versions and reverse dependencies of each package listed
    # are listed, as well as forward dependencies for each version.
    # Forward (normal) dependencies are those packages upon which the package
    # in question depends; reverse dependencies are those packages that depend
    # upon the package in question. Thus, forward dependencies must be
    # satisfied for a package, but reverse dependencies need not be.
    # For instance, apt-cache showpkg libreadline2 would produce output
    # similar to the following:
    #
    #          Package: libreadline2
    #          Versions: 2.1-12(/var/state/apt/lists/foo_Packages),
    #          Reverse Depends:
    #            libreadlineg2,libreadline2
    #            libreadline2-altdev,libreadline2
    #          Dependencies:
    #          2.1-12 - libc5 (2 5.4.0-0) ncurses3.0 (0 (null))
    #          Provides:
    #          2.1-12 -
    #          Reverse Provides:
    # Thus it may be seen that libreadline2, version 2.1-12, depends on
    # libc5 and ncurses3.0 which must be installed for libreadline2 to work.
    # In turn, libreadlineg2 and libreadline2-altdev depend on libreadline2.
    # If libreadline2 is installed, libc5 and ncurses3.0 (and ldso) must also
    # be installed; libreadlineg2 and libreadline2-altdev do not have to be
    # installed. For the specific meaning of the remainder of the output it
    # is best to consult the apt source code.
    #
    def showpkg(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "showpkg " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # stats displays some statistics about the cache. No further arguments are
    # expected. Statistics reported are:
    #
    # *  Total package names is the number of package names found in the cache.
    #
    # *  Normal packages is the number of regular, ordinary package names;
    #    these are packages that bear a one-to-one correspondence between
    #    their names and the names used by other packages for them in
    #    dependencies. The majority of packages fall into this category.
    #
    # *  Pure virtual packages is the number of packages that exist only as
    #    a virtual package name; that is, packages only "provide" the virtual
    #    package name, and no package actually uses the name. For instance,
    #    "mail-transport-agent" in the Debian GNU/Linux system is a pure
    #    virtual package; several packages provide "mail-transport-agent",
    #    but there is no package named "mail-transport-agent".
    #
    # *  Single virtual packages is the number of packages with only one package
    #    providing a particular virtual package. For example, in the Debian
    #    GNU/Linux system, "X11-text-viewer" is a virtual package, but only
    #    one package, xless, provides "X11-text-viewer".
    #
    # *  Mixed virtual packages is the number of packages that either provide
    #    a particular virtual package or have the virtual package name as the
    #    package name. For instance, in the Debian GNU/Linux system, "debconf"
    #    is both an actual package, and provided by the debconf-tiny package.
    #
    # *  Missing is the number of package names that were referenced in a
    #    dependency but were not provided by any package. Missing packages may
    #    be an evidence if a full distribution is not accessed, or if a
    #    package (real or virtual) has been dropped from the distribution.
    #    Usually they are referenced from Conflicts or Breaks statements.
    #
    # *  Total distinct versions is the number of package versions found in
    #    the cache; this value is therefore at least equal to the number of
    #    total package names. If more than one distribution (both "stable" and
    #    "unstable", for instance), is being accessed, this value can be
    #    considerably larger than the number of total package names.
    #
    # *  Total dependencies is the number of dependency relationships claimed
    #    by all of the packages in the cache.
    #
    def stats

      tmp = Tempfile.new('tmp')
      command = option_string() + "stats " + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # showsrc displays all the source package records that match the given
    # package names. All versions are shown, as well as all records that
    # declare the name to be a Binary.
    #
    def showsrc(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "showsrc " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # dump shows a short listing of every package in the cache.
    # It is primarily for debugging.
    #
    def dump

      tmp = Tempfile.new('tmp')
      command = option_string() + "dump " + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # dumpavail prints out an available list to stdout.
    # This is suitable for use with dpkg and is used by
    # the dselect method.
    #
    def dumpavail

      tmp = Tempfile.new('tmp')
      command = option_string() + "dumpavail " + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # unmet displays a summary of all unmet dependencies in the package cache.
    #
    def unmet

      tmp = Tempfile.new('tmp')
      command = option_string() + "unmet " + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # show performs a function similar to dpkg --print-avail;
    # it displays the package records for the named packages.
    #
    def show(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "show " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # search performs a full text search on all available package lists
    # for the POSIX regex pattern given, see regex. It searches the package
    # names and the descriptions for an occurrence of the regular
    # expression and prints out the package name and the short description,
    # including virtual package names. If 'full' is given then output identical
    # to show is produced for each matched package, and if 'names_only' is
    # given then the long description is not searched, only the package name is.
    #
    # Separate arguments can be used to specify multiple search patterns
    # that are and'ed together.
    #
    def search(regexp)

      tmp = Tempfile.new('tmp')
      regexp.collect! { |i| i + " " }
      command = option_string() + "search " + regexp.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end


    #
    # depends shows a listing of each dependency a package has and all the
    # possible other packages that can fulfill that dependency.
    #
    def depends(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "depends " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # rdepends shows a listing of each reverse dependency a package has.
    #
    def rdepends(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "rdepends " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # This command prints the name of each package APT knows.
    # The optional argument is a prefix match to filter the name list.
    # The output is suitable for use in a shell tab complete function and the
    # output is generated extremely quickly. This command is best used with
    # the 'generate' option.
    #
    # Note that a package which APT knows of is not necessarily available
    # to download, installable or installed, e.g. virtual packages are also
    # listed in the generated list.
    #
    def pkgnames(prefix)

      tmp = Tempfile.new('tmp')
      prefix.collect! { |i| i + " " }
      command = option_string() + "pkgnames " + prefix.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # dotty takes a list of packages on the command line and generates output
    # suitable for use by dotty from the GraphViz package. The result will be
    # a set of nodes and edges representing the relationships between the
    # packages. By default the given packages will trace out all dependent
    # packages; this can produce a very large graph. To limit the output to
    # only the packages listed on the command line, set
    # the APT::Cache::GivenOnly option.
    #
    # The resulting nodes will have several shapes; normal packages are boxes,
    # pure provides are triangles, mixed provides are diamonds,
    # missing packages are hexagons. Orange boxes mean recursion was stopped
    # [leaf packages], blue lines are pre-depends, green lines are conflicts.
    #
    def dotty(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "dotty " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # The same as dotty, only for xvcg from the VCG tool.
    #
    def xvcg(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "xvcg " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # policy is meant to help debug issues relating to the preferences file.
    # With no arguments it will print out the priorities of each source.
    # Otherwise it prints out detailed information about the priority
    # selection of the named package.
    #
    def policy(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "policy " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    #
    # apt-cache's madison command attempts to mimic the output format and
    # a subset of the functionality of the Debian archive management tool,
    # madison. It displays available versions of a package in a tabular
    # format. Unlike the original madison, it can only display information
    # for the architecture for which APT has retrieved package lists
    # (APT::Architecture).
    #
    def madison(packages)

      tmp = Tempfile.new('tmp')
      packages.collect! { |i| i + " " }
      command = option_string() + "madison " + packages.to_s + " 2> " + tmp.path
      success = system(command)
      if success
	      begin
          while (line = tmp.readline)
            line.chomp
            selected_string = line
          end
        rescue EOFError
          tmp.close
        end
	      return selected_string
      else
	      tmp.close!
	      return success
      end

    end

    private

    def option_string()
      ostring = "apt-cache "

      if @option
        ostring += "--option " + @option
      end

      if @config_file
        ostring += "--config-file " + @config_file
      end

      if @version
        ostring += "--version "
      end

      if @installed
        ostring += "--installed "
      end

      if @recurse
        ostring += "--recurse "
      end

      if @all_names
        ostring += "--all-names "
      end

      if @names_only
        ostring += "--names-only "
      end

      if @generate
        ostring += "--generate "
      end

      if @all_versions
        ostring += "--all-versions "
      end

      if @full
        ostring += "--full "
      end

      if @no_pre_depends
        ostring += "--no-pre-depends "
      end

      if @no_depends
        ostring += "--no-depends "
      end

      if @no_recommends
        ostring += "--no-recommends "
      end

      if @no_suggests
        ostring += "--no-suggests "
      end

      if @no_conflicts
        ostring += "--no-conflicts "
      end

      if @no_breaks
        ostring += "--no-breaks "
      end

      if @no_replaces
        ostring += "--no-replaces "
      end

      if @no_enhances
        ostring += "--no-enhances "
      end

      if @important
        ostring += "--important "
      end

      if @quiet
        ostring += "--quiet " + @quiet
      end

      if @src_cache
        ostring += "--src-cache " + @src_cache
      end

      if @pkg_cache
        ostring += "--pkg-cache " + @pkg_cache
      end

      return ostring

    end
  end


  #Dir[File.join(File.dirname(__FILE__), 'raptcache/**/*.rb')].sort.each { |lib| require lib }

