:Class  Dropbox_uc

    ∇ r←List;⎕IO;⎕ML ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      ⎕IO←⎕ML←1
      r←⎕NS''
      r.Name←'Dropbox'
      r.Desc←'User command that help solving Dropbox conflicts, if any'
      r.Group←''
     ⍝ Parsing rules for each:
      r.Parse←'-dry -version'
    ∇

    ∇ r←Run(Cmd Args);⎕IO;⎕ML;C;version;f1;f2;openCiderProjects;L;path;ind;dry
      :Access Shared Public
      ⎕IO←1 ⋄ ⎕ML←3
      version←0 Args.Switch'version'
      dry←0 Args.Switch'dry'
      C←⎕SE.Dropbox.CommTools
      :If f1←0<⎕SE.⎕NC'Dropbox.∆EXEC_IN_PROJECT'
          f1←1≡⎕SE.Dropbox.∆EXEC_IN_PROJECT
      :EndIf
      :If ~f1
      :AndIf f2←9=⎕SE.⎕NC'Cider'
      :AndIf f2←0<≢openCiderProjects←⎕SE.Cider.ListOpenProjects 0
      :AndIf f2←(⊂'#.Dropbox')∊openCiderProjects[;1]
          f2←1 C.YesOrNo'ExecInRoot@Would you like to execute code in #.Dropbox rather than ⎕SE.Dropbox?'
      :EndIf
      :If f1∨f2
          L←#.Dropbox.Dropbox
      :Else
          L←⎕SE.Dropbox
      :EndIf
      :If version
          r←L.Version ⋄ →0
      :EndIf
      path←''
      'Invalid number of arguments'Assert(≢Args.Arguments)∊0 1
      :If 0=≢Args.Arguments
          :If 9=⎕SE.⎕NC'Cider'
              openCiderProjects←⎕SE.Cider.ListOpenProjects 0
              :If 0=≢openCiderProjects
                  r←'No argument (path) specified, and no opened Cider available'
              :Else
                  :If 1=≢openCiderProjects
                      path←⊃openCiderProjects[1;2]
                  :Else
                      ind←'Select project to act on:'C.Select↓⍕openCiderProjects
                      :If 0=≢ind
                          r←'Cancelled by user'
                      :Else
                          path←⊃openCiderProjects[ind;2]
                      :EndIf
                  :EndIf
              :EndIf
          :Else
              r←'No argument (path) specified, and Cider is not available'
          :EndIf
      :Else
          path←↑Args.Arguments
          Assert L.##.FilesAndDirs.IsDir path
      :EndIf
      r←dry HandleDropboxConflictFiles path
      ⍝Done
    ∇

    ∇ r←level Help Cmd;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂']Dropbox [<path>] -version'
      :Case 1
          r,←⊂'You may either specify a path to a project or leave it to the user command'
          r,←⊂'to work the the project out if you use Cider.'
          r,←⊂' * If only one Cider project is open, ]Dropbox will act on it'
          r,←⊂' * If multiple Cider projects are open, you will be questioned'
          r,←⊂''
          r,←⊂'A list with all conflict files is established. The user command then compares'
          r,←⊂'the contents. If there is no real conflict, the conflicting file is deleted.'
          r,←⊂'At the moment, only text files can be compared. This restriction may be lifted'
          r,←⊂'at a later stage.'
          r,←⊂'For all real conflicts a list is returned by the user command.'
          r,←⊂''
          r,←⊂'-dry       Reports what it would do without actually doing it'
          r,←⊂'-version   Returns the version number. If specified anything else is ignored.'
      :Case 2
          r←'No detailed help available'
      :EndSelect
    ∇

    ∇ r←GetHomeFolder
      r←1⊃⎕NPARTS ##.SourceFile
    ∇

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11}

    ∇ r←dry HandleDropboxConflictFiles path;list;filename;filename2;msg;noOf;i
      noOf←≢list←L.ListAllConflictingFiles path
      :If 0=noOf
          r←'No Dropbox conflicts found'
      :Else
          ⎕←(⍕noOf),' Dropbox conflicts found'
          r←0 1⍴''
          :For i :In ⍳noOf
              filename←i⊃list
              filename2←DropConflictIndicator filename
              msg←⊂(⍕i),' of ',⍕noOf
              :Trap 1 92
                  :If ≡/{↑⎕NGET ⍵}¨filename filename2
                      msg,←⊂(1+≢path)↓filename
                      msg,←⊂'  is identical with:'
                      msg,←⊂(1+≢path)↓filename2
                      :If dry
                          msg,←⊂'  and would therefore be deleted if it wasn''t for the -dry flag'
                      :Else
                          msg,←⊂'  and therefore deleted'
                      :EndIf
                      ⎕←⊃msg
                      {}⎕NDELETE⍣(~dry)⊢filename
                  :Else
                      msg,←⊂'Added to list of serious conflicts'
                      ⎕←⊃msg
                      r⍪←⊂filename
                  :EndIf
              :Case 1
                  msg←⊂'Files cannot be compared due to a WS FULL:'
                  msg,←⊂filename
                  msg,←⊂filename2
                  ⎕←⊃msg
              :Case 92
                  msg←⊂'Files cannot be compared due to a TRANSLATION ERROR:'
                  msg,←⊂filename
                  msg,←⊂filename2
                  ⎕←⊃msg
              :EndTrap
          :EndFor
      :EndIf
    ∇

    ∇ r←DropConflictIndicator tx;lf;b;tx2;tx3
      lf←⌽'conflicted copy'  ⍝ Look for
      tx2←⌽tx
      b←lf⍷tx2
      tx3←(⌈\1+b)⊆tx2
      r←{⍵↑⍨¯1+⍵⍳')'}1⊃tx3
      r,←{⍵↓⍨1+⍵⍳'('}2⊃tx3
      r←⌽r
    ∇

:EndClass
