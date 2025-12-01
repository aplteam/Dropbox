# Dropbox

When Dropbox thinks that there is a conflict it creates a copy of the original file and injects `(<user-name>'s conflicted copy YYYY-MM-DD)` after the filename and before the extension. Experience tells that more often than not this is a false alarm.

This user command establishes a list with all conflicting files and then compares them with the original. If the match, the conflicting copy is deleted.

All remaining conflicting files are returned by the user command.

`]Dropbox` takes a path as argument. If you manage your projects with Cider you can leave it to the user command to work out the project:
If there is only one project open, `]Dropbox` will act on it, otherwise the user will be questioned.