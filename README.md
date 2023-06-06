<center>
<img src="https://i.imgur.com/eA2MXLC.gif" height="500px"></img>
</center>

# Infinite Grouped List

Brings together infinite scrolling, group-based item organization, and numerous other enhancements to improve the end-user experience.

### Key Features

- **Infinite Scrolling**: The widget supports loading more data as the user reaches the end of the list. This is essential for handling large datasets without overwhelming the user or their device.

- **Grouping of Items**: The widget can organize items into groups based on user-defined criteria. This helps to make sense of large amounts of data by breaking it down into manageable chunks.

- **Customizable Loading and Error States**: You can provide custom widgets to be displayed while data is being loaded or if an error occurs. This allows for a seamless, branded experience.

- **Pull-to-Refresh**: The widget incorporates a pull-to-refresh feature, letting users manually trigger a refresh of the list's content.

- **Sticky Group Headers**: Headers stick to the top of the list as the user scrolls, making it easier to understand the context of the data they're viewing. Can be changed.

### Usage

To use the InfiniteGroupedList widget, you need to provide several callbacks:

`onLoadMore`: A function that fetches more data.
`itemBuilder`: A function that builds the individual list items.
`groupBy`: A function that defines the criterion for grouping items.
`groupCreator`: A function that assigns a name to each group.

Additionally, the widget provides an `InfiniteGroupedListController`. This controller allows for programmatically fetching data and refreshing the list, providing you with precise control over the list's behavior.

The InfiniteGroupedList widget is a comprehensive solution for any use case that involves displaying large amounts of data in an organized, easy-to-navigate manner.

Examples can be found [here](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/group_by_date_example.dart) & [here](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/group_by_type_example.dart).
