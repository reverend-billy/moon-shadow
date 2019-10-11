
'''
    Class definitions defining formatting for various files used by
    debian packaging; that is, files found in the debian/ dir.
'''

class SymLinks():
    '''
        Formatting  used for generating symbolic links in the packaging
        directory (commonly debian/<pkg-name> ) used for staging the build.

        Basic format is <src>\t<dst> where src is the location in the built
        tree (as in tmp/foo/bah/dobo.fy) and dst is the
    '''

    def __init__(self, pkgname):
        '''
            Initialize in the name of pkgname for creating a links file
            suitable for use in building Debian packages using dpkg or
            dh_build.
        '''

        self.filename = pkgname + ".links"
        self.entries = list("")

    def add_entry(self, target, *args):
        '''
            Similar to the 'ln' command save the paths are absolute
            with the leading '/' optional.

            target  : The binary file used as the base for the link
            *args   : The set of links to set to target. E.g. libs.
        '''

        links = list(args)
        if not target in self.entries:
#           print("initial set for " + target)
            self.entries.append([target, "\t\n\t\t\t".join(links)])
#           print("===(" + str(len(self.entries)) + ") " + str(self.entries[0]))
#       if  target in self.entries[0]:
#           print("append " + link + " to " + target)
#           self.entries[0][1].append(link)

    def flush(self):
        '''
            Create the <pkg>.links file from the set of dictionaries.
        '''

        with open(self.filename, 'w') as f_f:
            for alpha in self.entries:
                f_f.write("\t".join(alpha))
                f_f.write("\n")

    def dump(self):
        '''
            reveal contents of data dictionary.
        '''
        for alpha in self.entries:
            print("\t".join(alpha))

