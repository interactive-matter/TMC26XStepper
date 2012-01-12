class DataTable {
  
  LinkedList<Integer> dataList = new LinkedList<Integer>();
  int maxEntries;
  
  DataTable(int maxEntries) {
    this.maxEntries = maxEntries;
  }
  
  void addData(int value) {
    dataList.add(value);
    if (dataList.size()>maxEntries) {
      dataList.remove();
    }
  }
  
  int getSize() {
    return dataList.size();
  }
  
  int getEntry(int position) {
    return dataList.get(position);
  }
}
