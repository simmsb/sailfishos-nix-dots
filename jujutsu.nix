{ pkgs
, config
, flake
, ...
}:
{
  home.packages = [
    # pkgs.watchman  causes huge build?
    pkgs.difftastic
    pkgs.jj-starship
    pkgs.jjui
  ];
  programs.jujutsu = {
    enable = true;
    ediff = false;
    settings = {
      user = {
        name = "Ben Simms";
        email = "ben@bensimms.moe";
      };

      aliases.tug = [
        "bookmark"
        "move"
        "--from"
        "heads(::@ & bookmarks())"
        "--to"
        "closest_pushable(@)"
      ];
      aliases.cleanup = [
        "abandon"
        "::mutable() ~ (::bookmarks() | bookmarks()::)"
      ];
      aliases.prunesquashes = [
        "util"
        "exec"
        "--"
        "bash"
        "-c"
        ''
          set -euo pipefail
          git-branch-delete-merged ''${1:-origin/master}
          jj git import
        ''
        ""
      ];
      aliases.syncmine = [
        "rebase"
        "-d"
        "trunk()"
        "-b"
        "bookmarks(glob:'simmsb/*')"
      ];
      aliases.syncallmutable = [
        "rebase"
        "-s"
        "all:roots(trunk()..mutable())"
        "-d"
        "trunk()"
      ];

      git = {
        write-change-id-header = true;
        private-commits = "private()";
        subprocess = true;
      };

      # disabled, keeps causing index locks
      # fsmonitor = {
      #   watchman.register-snapshot-trigger = true;
      #   backend = "watchman";
      # };

      revsets = {
        "log" =
          "ancestors(trunk(), 5) | heads(::coalesce(trunk(), root()) & ::present(@))::present(@) | @:: | recently_touched_unbookmarked() | relevant_bookmarks_log()";
      };

      revset-aliases = {
        "stashed_bookmarks()" = "bookmarks(glob:'stashed/*')";
        "stashed_bookmarks_log()" = "trunk()..stashed_bookmarks()";
        "relevant_bookmarks()" = "my_bookmarks() ~ stashed_bookmarks()";
        "relevant_bookmarks_log()" = "trunk()..relevant_bookmarks()";
        "my_bookmarks()" = "bookmarks() & mine()";
        "my_bookmarks_log()" = "trunk()..my_bookmarks()";
        # "immutable_heads()" = "builtin_immutable_heads()";
        "private()" = "description(glob:'private:*')";
        "closest_pushable(to)" =
          "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
        "recently_touched_unbookmarked()" =
          "(mine() & committer_date(after:\"14 days ago\")) ~ my_bookmarks_log()";
      };

      fix = {
        tools = {
          ormolu = {
            command = [
              "ormolu"
              "--stdin-input-file=$file"
              "-c"
            ];
            patterns = [ "glob:'**/*.hs'" ];
          };
          # prettier = {
          #   command = ["prettier" "--stdin-input-file=$file" "-c"];
          #   patterns = ["glob:'**/*.hs'"];
          # };
        };
      };

      ui = {
        editor = "nvim";
        default-command = "log";
        diff-formatter = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
        conflict-marker-style = "git";
        diff-instructions = false;
      };

      # ui.diff-editor = [ "scm-diff-editor" "--dir-diff" "$left" "$right" ];

      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';

        log_node = ''
          if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
            "◇",
            builtin_log_node
           )
        '';
      };

      template-aliases = {
        "format_timestamp(timestamp)" = "timestamp.ago()";
        "in_branch(commit)" = "commit.contained_in(\"immutable_heads()..bookmarks()\")";
      };
    };
  };
}
