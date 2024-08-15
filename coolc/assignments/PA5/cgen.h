#include <assert.h>
#include <stdio.h>
#include "emit.h"
#include "cool-tree.h"
#include "symtab.h"
#include <stack>
#include <vector>
#include <list>
#include <map>

enum Basicness     {Basic, NotBasic};
#define TRUE 1
#define FALSE 0

class CgenClassTable;
typedef CgenClassTable *CgenClassTableP;

class CgenNode;
typedef CgenNode *CgenNodeP;

class CgenClassTable : public SymbolTable<Symbol,CgenNode> {
private:
   List<CgenNode> *nds;
   ostream& str;
   int stringclasstag;
   int intclasstag;
   int boolclasstag;

   /// ADITION
   std::vector<CgenNode*> _class_nodes;
   std::map<Symbol, int> m_class_tags;


// The following methods emit code for
// constants and global declarations.

   void code_global_data();
   void code_global_text();
   void code_bools(int);
   void code_select_gc();
   void code_constants();

   /// ADITION
   void code_class_methods();
   void code_class_nameTab();
   void code_protObjs();
   void code_class_objTab();
   void code_class_inits();
   void code_dispatchTabs();

// The following creates an inheritance graph from
// a list of classes.  The graph is implemented as
// a tree of `CgenNode', and class names are placed
// in the base class symbol table.

   void install_basic_classes();
   void install_class(CgenNodeP nd);
   void install_classes(Classes cs);
   void build_inheritance_tree();
   void set_relations(CgenNodeP nd);
public:
   CgenClassTable(Classes, ostream& str);
   void code();
   CgenNodeP root();
   
   /// ADITION 
   std::vector<CgenNode*> GetClassNodes();
   std::map<Symbol, int> GetClassTags();
   CgenNode* GetClassNode(Symbol class_name) {
      GetClassNodes();
      return _class_nodes[m_class_tags[class_name]];
   }
};


class CgenNode : public class__class {
private: 
   CgenNodeP parentnd;                        // Parent of class
   List<CgenNode> *children;                  // Children of class
   Basicness basic_status;                    // `Basic' if class is basic
                                              // `NotBasic' otherwise

public:
   CgenNode(Class_ c,
            Basicness bstatus,
            CgenClassTableP class_table);

   void add_child(CgenNodeP child);
   List<CgenNode> *get_children() { return children; }
   void set_parentnd(CgenNodeP p);
   CgenNodeP get_parentnd() { return parentnd; }
   int basic() { return (basic_status == Basic); }


public:
   CgenNode(Class_ c,
            Basicness bstatus,
            CgenClassTableP class_table);

   void add_child(CgenNodeP child);
   List<CgenNode> *get_children() { return children; }

   std::vector<CgenNode*> GetChildren() {
        std::vector<CgenNode*> ret;
        List<CgenNode>* _children = get_children();
        while (_children != nullptr) {
            ret.push_back(_children->hd());
            _children = _children->tl();
        }
        return ret;
    }

   void set_parentnd(CgenNodeP p);
   CgenNodeP get_parentnd() { return parentnd; }
   int basic() { return (basic_status == Basic); }

   void code_protObj(ostream& s);
   void code_init(ostream& s);
   void code_methods(ostream& s);

   std::vector<method_class*> GetMethods();
   std::vector<method_class*> m_methods;

   std::vector<method_class*> GetFullMethods();
   std::vector<method_class*> m_full_methods;

   std::map<Symbol, Symbol> GetDispatchClassTab();
   std::map<Symbol, Symbol> m_dispatch_class_tab;

   std::map<Symbol, int> GetDispatchIdxTab();
   std::map<Symbol, int> m_dispatch_idx_tab;

   std::vector<attr_class*> GetAttribs();
   std::vector<attr_class*> m_attribs;

   std::vector<attr_class*> GetFullAttribs();
   std::vector<attr_class*> m_full_attribs;

   std::map<Symbol, int> GetAttribIdxTab();
   std::map<Symbol, int> m_attrib_idx_tab;

   std::vector<CgenNode*> GetInheritance();
   std::vector<CgenNode*> inheritance;

   int class_tag;
};



class BoolConst 
{
 private: 
  int val;
 public:
  BoolConst(int);
  void code_def(ostream&, int boolclasstag);
  void code_ref(ostream&) const;
};

/// ADITION
class CurrentStateCode
{
public:
   CurrentStateCode() : _class_node(nullptr) {}

   void EnterScope() {
      _scope_lengths.push_back(0);
   }

   void ExitScope() {
      for (int i = 0; i < _scope_lengths[_scope_lengths.size() - 1]; ++i) {
         _var_idx_tab.pop_back();
      }
      
      _scope_lengths.pop_back();
   }

   int LookUpAttrib(Symbol sym) {
      std::map<Symbol, int> attrib_idx_tab = _class_node->GetAttribIdxTab();
      if (attrib_idx_tab.find(sym) != attrib_idx_tab.end()) {
         return attrib_idx_tab[sym];
      }
      return -1;
   }

   // The vars are in reverse order.
   int LookUpVar(Symbol sym) {
      for (int idx = _var_idx_tab.size() - 1; idx >= 0; --idx) {
         if (_var_idx_tab[idx] == sym) {
            return _var_idx_tab.size() - 1 - idx;
         }
      }

      return -1;
   }

   int AddVar(Symbol sym) {
      _var_idx_tab.push_back(sym);
      ++_scope_lengths[_scope_lengths.size() - 1];
      return _var_idx_tab.size() - 1;
   }

   int AddObstacle();

   int LookUpParam(Symbol sym) {
      for (int idx = 0; idx < _param_idx_tab.size(); ++idx) {
         if (_param_idx_tab[idx] == sym) {
            return _param_idx_tab.size() - 1 - idx;
         }
      }
      return -1;
   }

   int AddParam(Symbol sym) {
      _param_idx_tab.push_back(sym);
      return _param_idx_tab.size() - 1;
   }

   // Controlo numero de variaveis no escopo local
   std::vector<int> _scope_lengths;
   
   // tabela de simbolos das variaveis locais
   std::vector<Symbol> _var_idx_tab;

   // tabela de simbolos dos parametros
   std::vector<Symbol> _param_idx_tab;

   // Salvo informacoes da classe atual
   CgenNode* _class_node;
};