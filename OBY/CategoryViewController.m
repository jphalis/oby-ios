//
//  CategoryViewController.m
//

#import "CategoryViewController.h"


@interface CategoryViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *arrCategory;
    __weak IBOutlet UITableView *tblVw;
}

- (IBAction)onBack:(id)sender;

@end

@implementation CategoryViewController

// Need to fix this to be dynamic based on admin entries
- (void)viewDidLoad {
    arrCategory = [[NSMutableArray alloc]initWithObjects:@"Just Because",@"Sports & Fitness",@"Nightlife",@"Style",@"Lol",@"Pay it Forward",@"University",@"Food",@"Fall",@"", nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrCategory count];    //count number of row from counting array hear cataGorry is An Array
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [arrCategory objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblVw cellForRowAtIndexPath:indexPath];
    
    if(indexPath.row == 9){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return;
    }
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [self.delegate chooseCategory:[arrCategory objectAtIndex:indexPath.row]selectedIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
